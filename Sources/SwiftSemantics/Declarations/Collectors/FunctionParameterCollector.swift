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
        super.init()
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
        // If closure the parameter holds a closure parameter declaration - visit children to pick it up
        if parameterContainsClosureChildNode(node) {
            return .visitChildren
        }
        let parameter = StandardParameter(node)
        parameters.append(parameter)
        return .skipChildren
    }

    override func visit(_ node: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
        let parameter = StandardParameter(node)
        parameters.append(parameter)
        return .skipChildren
    }

    // MARK: - Helpers
    
    func parameterContainsClosureChildNode(_ node: FunctionParameterSyntax) -> Bool {
        var nextToken: TokenSyntax? = node.firstToken
        while nextToken != nil {
            if nextToken?.parent?.syntaxNodeType == FunctionTypeSyntax.self {
                return true
            }
            nextToken = nextToken?.nextToken
        }
        return false
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
