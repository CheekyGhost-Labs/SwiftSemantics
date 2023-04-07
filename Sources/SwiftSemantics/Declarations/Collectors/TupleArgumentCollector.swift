//
//  TupleArgumentCollector.swift
//  
//
//  Created by Michael O'Brien on 3/12/2022.
//

import SwiftSyntax

/// Takes a `TupleTypeElementListSyntax` node and walks through the children to collect an array of `ParameterType` items.
class TupleArgumentCollector: Collector {

    // MARK: - Properties

    /// Array of collected parameters.
    private(set) var parameters: [any ParameterType] = []

    /// The root node being iterated over
    var node: TupleTypeElementListSyntax

    // MARK: - Lifecycle

    required init(_ node: TupleTypeElementListSyntax) {
        self.node = node
        super.init(viewMode: .fixedUp)
    }

    // MARK: - Helpers

    static func collect(_ node: TupleTypeElementListSyntax) -> [any ParameterType] {
        let collector = TupleArgumentCollector(node)
        return collector.collect()
    }

    func collect() -> [any ParameterType] {
        walk(node._syntaxNode)
        return parameters
    }

    // MARK: - Overrides

    override func visit(_ node: TupleTypeSyntax) -> SyntaxVisitorContinueKind {
        let parameter = TupleParameter(node)
        parameters.append(parameter)
        return .skipChildren
    }

    override func visit(_ node: TupleTypeElementSyntax) -> SyntaxVisitorContinueKind {
        // Tuple Type Element's wrap a `TupleTypeSyntax` - visit children to let the collector pick up the element.
        return .visitChildren
    }

    override func visit(_ node: TupleTypeElementListSyntax) -> SyntaxVisitorContinueKind {
        // We are keeping this shallow. So if the node is the initialized node we can visit children
        if node._syntaxNode.id == node.id {
            return .visitChildren
        }
        return .visitChildren
    }

    override func visit(_ node: FunctionTypeSyntax) -> SyntaxVisitorContinueKind {
        let parameter = ClosureParameter(node)
        parameters.append(parameter)
        return .skipChildren
    }

    override func visit(_ node: SimpleTypeIdentifierSyntax) -> SyntaxVisitorContinueKind {
        if node.firstToken?.text == "Result" {
            // Result parameter
            let parameter = ResultParameter(node)
            parameters.append(parameter)
            return .skipChildren
        }
        let parameter = StandardParameter(node)
        parameters.append(parameter)
        return .skipChildren
    }
}
