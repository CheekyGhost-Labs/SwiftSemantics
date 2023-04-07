//
//  TupleOptionalCollector.swift
//
//
//  Created by Michael O'Brien on 3/12/2022.
//

import SwiftSyntax

class TupleOptionalCollector: Collector {

    // MARK: - Properties

    /// The result from the collector
    private(set) var isOptional: Bool?

    var foundTypeParent: Bool = false

    // MARK: - Helpers

    static func collect(_ node: Syntax) -> Bool {
        let collector = TupleOptionalCollector(viewMode: .fixedUp)
        collector.walk(node)
        return collector.isOptional ?? false
    }

    // MARK: - Overrides

    override func visit(_ node: TypeAnnotationSyntax) -> SyntaxVisitorContinueKind {
        foundTypeParent = true
        return .visitChildren
    }

    override func visit(_ node: TupleTypeSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }

    override func visit(_ node: TupleTypeElementSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: TupleTypeElementListSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }

    override func visit(_ node: OptionalTypeSyntax) -> SyntaxVisitorContinueKind {
        guard foundTypeParent else { return .skipChildren }
        let parentType = node.parent?.syntaxNodeType
        if parentType == TupleTypeElementSyntax.self || parentType == TypeAnnotationSyntax.self {
            isOptional = true
        }
        return .skipChildren
    }
}
