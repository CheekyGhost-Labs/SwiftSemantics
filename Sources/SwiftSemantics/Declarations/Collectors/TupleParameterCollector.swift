//
//  TupleDeclarationCollector.swift
//  
//
//  Created by Michael O'Brien on 3/12/2022.
//

import SwiftSyntax

class TupleParameterCollector: SyntaxVisitor {
    
    /// Optional result value assigned when a closure declaration has been found.
    private var result: TupleParameter?
    
    // MARK: - Helpers
    
    static func collect(_ node: Syntax) -> TupleParameter? {
        let collector = TupleParameterCollector(viewMode: .fixedUp)
        collector.walk(node)
        return collector.result
    }
    
    // MARK: - Overrides

    override func visit(_ node: TupleTypeSyntax) -> SyntaxVisitorContinueKind {
        guard result == nil else { return .skipChildren }
        let embeddedLists = node.children(viewMode: .fixedUp).filter { $0.syntaxNodeType == TupleTypeElementListSyntax.self }
        if embeddedLists.count == 1, TupleTypeElementListSyntax(embeddedLists[0]._syntaxNode) != nil {
            return .visitChildren
        }
        result = TupleParameter(node)
        return .skipChildren
    }

    override func visit(_ node: TupleTypeElementSyntax) -> SyntaxVisitorContinueKind {
        return .visitChildren
    }

    override func visit(_ node: TupleTypeElementListSyntax) -> SyntaxVisitorContinueKind {
        guard result == nil else { return .skipChildren }
        let tuple = TupleParameter(node)
        if tuple.arguments.count == 1, tuple.arguments[0] is TupleParameter {
            return .visitChildren
        }
        result = tuple
        return .skipChildren
    }
}
