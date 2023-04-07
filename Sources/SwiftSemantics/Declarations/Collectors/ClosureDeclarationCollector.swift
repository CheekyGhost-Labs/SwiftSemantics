//
//  ClosureDeclarationResolver.swift
//  
//
//  Created by Michael O'Brien on 3/12/2022.
//

import SwiftSyntax

class ClosureDeclarationCollector: SyntaxVisitor {
    
    /// Optional result value assigned when a closure declaration has been found.
    private var result: ClosureDeclaration?
    
    // MARK: - Helpers
    
    static func collect(_ node: Syntax) -> ClosureDeclaration? {
        let collector = ClosureDeclarationCollector(viewMode: .fixedUp)
        collector.walk(node)
        return collector.result
    }
    
    // MARK: - Overrides

    override func visit(_ node: FunctionTypeSyntax) -> SyntaxVisitorContinueKind {
        result = ClosureDeclaration(node)
        return .skipChildren
    }
}
