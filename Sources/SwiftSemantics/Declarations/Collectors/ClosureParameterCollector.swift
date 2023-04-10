//
//  ClosureDeclarationResolver.swift
//  
//
//  Created by Michael O'Brien on 3/12/2022.
//

import SwiftSyntax

class ClosureParameterCollector: SyntaxVisitor {
    
    /// Optional result value assigned when a closure declaration has been found.
    private var result: ClosureParameter?
    
    // MARK: - Helpers
    
    static func collect(_ node: Syntax) -> ClosureParameter? {
        let collector = ClosureParameterCollector(viewMode: .fixedUp)
        collector.walk(node)
        return collector.result
    }
    
    // MARK: - Overrides

    override func visit(_ node: FunctionTypeSyntax) -> SyntaxVisitorContinueKind {
        result = ClosureParameter(node)
        return .skipChildren
    }
}
