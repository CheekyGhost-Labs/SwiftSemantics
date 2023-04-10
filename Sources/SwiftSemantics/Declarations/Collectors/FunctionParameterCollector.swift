//
//  FunctionParameterCollector.swift
//  
//
//  Created by Michael O'Brien on 3/12/2022.
//

import SwiftSyntax

class FunctionParameterCollector: Collector {

    // MARK: - Properties

    /// Array of collected parameters.
    private(set) var parameters: [any ParameterType] = []

    /// The root node being iterated over
    var node: FunctionParameterListSyntax

    // MARK: - Lifecycle

    required init(_ node: FunctionParameterListSyntax) {
        self.node = node
        super.init(viewMode: .fixedUp)
    }

    // MARK: - Helpers

    static func collect(_ node: FunctionParameterListSyntax) -> [any ParameterType] {
        let collector = FunctionParameterCollector(node)
        return collector.collect()
    }

    func collect() -> [any ParameterType] {
        walk(node._syntaxNode)
        return parameters
    }

    // MARK: - Overrides

    override func visit(_ node: FunctionParameterListSyntax) -> SyntaxVisitorContinueKind {
        return.visitChildren
    }

    override func visit(_ node: AttributedTypeSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }

    override func visit(_ node: TupleTypeSyntax) -> SyntaxVisitorContinueKind {
        let parameter = TupleParameter(node)
        parameters.append(parameter)
        return .skipChildren
    }

    override func visit(_ node: TupleTypeElementListSyntax) -> SyntaxVisitorContinueKind {
        if let parent = resolveParentTupleFromListSyntax(node) {
            let parameter = TupleParameter(parent)
            parameters.append(parameter)
        }
        return .skipChildren
    }

    override func visit(_ node: FunctionTypeSyntax) -> SyntaxVisitorContinueKind {
        let parameter = ClosureParameter(node)
        parameters.append(parameter)
        return .skipChildren
    }

    override func visit(_ node: OptionalTypeSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }

    override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        if let closure = ClosureParameterCollector.collect(node._syntaxNode) {
            parameters.append(closure)
        } else if let tuple = TupleParameterCollector.collect(node._syntaxNode) {
            parameters.append(tuple)
        } else {
            let parameter = StandardParameter(node)
            parameters.append(parameter)
        }
        return .skipChildren
    }

    override func visit(_ node: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
        let parameter = StandardParameter(node)
        parameters.append(parameter)
        return .skipChildren
    }

    // MARK: - Helpers
    
    func parameterContainsClosureChildNode(_ node: FunctionParameterSyntax) -> Bool {
        var result: Bool = false
        if let optionalChild = node.children(viewMode: .fixedUp).first(where: { $0.syntaxNodeType == OptionalTypeSyntax.self }) {
            result = ClosureParameterCollector.collect(optionalChild._syntaxNode) != nil
        } else {
            result = node.children(viewMode: .fixedUp).contains(where: {
                ClosureParameterCollector.collect($0._syntaxNode) != nil
            })
        }
        return result
    }

    func resolveParentTupleFromListSyntax(_ node: TupleTypeElementListSyntax) -> TupleTypeSyntax? {
        var parentNode = node.parent
        while parentNode != nil {
            if let parent = parentNode, parent.syntaxNodeType == TupleTypeSyntax.self {
                return TupleTypeSyntax(parent._syntaxNode)
            }
            parentNode = parentNode?.parent
        }
        return nil
    }
}
