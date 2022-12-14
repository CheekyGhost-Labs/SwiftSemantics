//
//  ClosureInputCollector.swift
//  
//
//  Created by Michael O'Brien on 3/12/2022.
//

import SwiftSyntax

/// Takes a `FunctionTypeSyntax` node and walks through the children to collect an array of `ParameterType` items.
class ClosureArgumentCollector: Collector {

    // MARK: - Properties

    /// The resolved type string for the closure input tuple/element.
    fileprivate(set) var type: String = ""

    /// Array of collected input parameters.
    fileprivate(set) var arguments: [any ParameterType] = []

    /// Bool whether the arrow separator has been detected yet.
    private(set) var arrowDetected: Bool = false

    /// The root node being iterated over
    var node: FunctionTypeSyntax
    
    /// Bool whether the parameter represents a void.
    /// **Note:** `isVoid` is considered true when the parameters are empty, or contain a single parameter that matches one of the following:
    /// `["Void","(Void)","Void?","(Void?)","()","(())","()?","(()?)"]`
    var isVoid: Bool {
        guard !arguments.isEmpty else { return true }
        guard arguments.count == 1 else { return false }
        return arguments.allSatisfy { Utils.isVoidType($0.type) }
    }

    // MARK: - Lifecycle

    required init(_ node: FunctionTypeSyntax) {
        self.node = node
        super.init()
    }

    // MARK: - Helpers

    static func collectInputs(_ node: FunctionTypeSyntax) -> (parameters: [any ParameterType], type: String, isVoid: Bool) {
        let collector = ClosureInputParameterCollector(node)
        return collector.collect()
    }
    
    static func collectOutputs(_ node: FunctionTypeSyntax) -> (parameters: [any ParameterType], type: String, isVoid: Bool) {
        let collector = ClosureOutputParameterCollector(node)
        return collector.collect()
    }
    
    static func collect(_ node: FunctionTypeSyntax) -> (parameters: [any ParameterType], type: String, isVoid: Bool) {
        let collector = Self(node)
        return collector.collect()
    }

    @discardableResult
    func collect() -> (parameters: [any ParameterType], type: String, isVoid: Bool) {
        walk(node._syntaxNode)
        return (arguments, type, isVoid)
    }

    // MARK: - Overrides
    
    override func visit(_ node: FunctionTypeSyntax) -> SyntaxVisitorContinueKind {
        // We are keeping this shallow. So if the node is the initialized node we can visit children
        guard self.node.id != node.id else { return .visitChildren }
        let parameter = ClosureParameter(node)
        arguments.append(parameter)
        return .skipChildren
    }
    
    override func visit(_ node: TokenSyntax) -> SyntaxVisitorContinueKind {
        if node.tokenKind == .arrow {
            arrowDetected = true
        }
        return .skipChildren
    }
    
    override func visit(_ node: TupleTypeSyntax) -> SyntaxVisitorContinueKind {
        let parameter = TupleParameter(node)
        arguments.append(parameter)
        return .skipChildren
    }

    override func visit(_ node: TupleTypeElementSyntax) -> SyntaxVisitorContinueKind {
        // Tuple Type Element's wrap a `TupleTypeSyntax` - visit children to let the collector pick up the element.
        return .visitChildren
    }

    override func visit(_ node: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
        let parameter = StandardParameter(node)
        type = node.description
        arguments.append(parameter)
        return .skipChildren
    }
}

/// Visitor that walks and assigns the root return type and optional postifx for the closure return type
class ClosureInputParameterCollector: ClosureArgumentCollector {
    
    override func visit(_ node: TupleTypeSyntax) -> SyntaxVisitorContinueKind {
        guard !arrowDetected else { return .skipChildren }
        return super.visit(node)
    }

    override func visit(_ node: TupleTypeElementSyntax) -> SyntaxVisitorContinueKind {
        guard !arrowDetected else { return .skipChildren }
        return super.visit(node)
    }

    override func visit(_ node: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
        guard !arrowDetected else { return .skipChildren }
        return super.visit(node)
    }

    override func visit(_ node: TupleTypeElementListSyntax) -> SyntaxVisitorContinueKind {
        guard !arrowDetected else { return .skipChildren }
        if node.children.count == 1, node.children.first?.syntaxNodeType == TupleTypeElementSyntax.self {
            let parameter = TupleParameter(node)
            // Because why not someone might declare a closure as `((Void) -> String?)` which swift treats as `(() -> String?)` which is `()`
            // This declaration is **technically** a tuple from a syntax perspective, for a closure we want to treat it as a single parameter with a `Void` type
            // Fortunately Swift compiler warns against these and has a `fix` button - but no enforcement (yet) 🙃
            if parameter.arguments.count == 1 {
                if let tupleArgument = parameter.arguments[0] as? TupleParameter, tupleArgument.arguments.count > 1 {
                    return .visitChildren
                }
                return Utils.isVoidType(parameter.arguments[0].type) ? .skipChildren : .visitChildren
            } else if parameter.arguments.isEmpty {
                type = parameter.description
                return .skipChildren
            }
            arguments.append(parameter)
            type = parameter.description
            return .skipChildren
        }
        return .visitChildren
    }
}


/// Visitor that walks and assigns the root return type and optional postifx for the closure return type
class ClosureOutputParameterCollector: ClosureArgumentCollector {
    
    // MARK: - Properties

    /// Bool flag whether the root child node has been detected yet
    var rootNodeDetected: Bool = false
    
    // MARK: - Overrides

    override func collect() -> (parameters: [any ParameterType], type: String, isVoid: Bool) {
        super.collect()
        if arguments.count == 1, Utils.isVoidType(arguments[0].type) {
            arguments = []
        }
        return (arguments, type, isVoid)
    }

    override func visit(_ node: TupleTypeSyntax) -> SyntaxVisitorContinueKind {
        guard arrowDetected else { return .skipChildren }
        if !rootNodeDetected {
            type = node.description
            rootNodeDetected = true
        }
        // In any wrapped scenario the first `tuple` is the container for result elements. These arguments
        // should be essentially pulled out into the collection rather than be treated as a single tuple output.
        let embeddedLists = node.children.filter { $0.syntaxNodeType == TupleTypeElementListSyntax.self }
        if embeddedLists.count == 1, let listNode = TupleTypeElementListSyntax(embeddedLists[0]._syntaxNode) {
            let parameter = TupleParameter(listNode)
            if parameter.arguments.count == 1 {
                // If the embedded argument is a tuple
                guard let tuple = parameter.arguments[0] as? TupleParameter else {
                    arguments.append(contentsOf: parameter.arguments)
                    return .skipChildren
                }
                if tuple.arguments.count == 1, Utils.isVoidType(tuple.arguments[0].type) {
                    return .skipChildren
                }
                arguments.append(contentsOf: tuple.arguments)
                return .skipChildren
            } else {
                // Otherwise, as a wrapped tuple, can just append the inner arguments
                arguments.append(contentsOf: parameter.arguments)
                return .skipChildren
            }
        }
        return super.visit(node)
    }

    override func visit(_ node: TokenSyntax) -> SyntaxVisitorContinueKind {
        guard arrowDetected else { return super.visit(node) }
        if node.tokenKind == .postfixQuestionMark {
            type += node.text
            return .skipChildren
        }
        return .skipChildren
    }

    override func visit(_ node: TupleTypeElementListSyntax) -> SyntaxVisitorContinueKind {
        return arrowDetected ? .visitChildren : .skipChildren
    }
    
    override func visit(_ node: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
        guard arrowDetected else { return .skipChildren }
        if !rootNodeDetected {
            type = node.description
            rootNodeDetected = true
        }
        return super.visit(node)
    }
}
