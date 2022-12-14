//
//  File.swift
//  
//
//  Created by Michael O'Brien on 5/12/2022.
//

import SwiftSyntax

extension Utils {

    enum SwiftSyntax {

        static func getOptionalChild(_ syntax: SyntaxProtocol?) -> OptionalTypeSyntax? {
            syntax?.children.compactMap({ OptionalTypeSyntax($0._syntaxNode) }).first
        }

        static func getTupleChild(_ syntax: SyntaxProtocol?) -> SyntaxProtocol? {
            syntax?.children.first(where: {
                $0.syntaxNodeType == TupleTypeSyntax.self ||
                $0.syntaxNodeType == TupleTypeElementListSyntax.self ||
                $0.syntaxNodeType == TupleTypeElementSyntax.self
            })
        }

        static func isVariableTupleDeclarationOptional(_ node: PatternBindingSyntax) -> Bool {
            guard let typeSyntax = node.children.compactMap({ TypeAnnotationSyntax($0._syntaxNode) }).first else { return false }
            if getOptionalChild(typeSyntax) != nil { return true }
            // Root optional not found - iterate through expected child variations
            var nextChild = getTupleChild(typeSyntax)
            while nextChild != nil {
                if let node = getOptionalChild(nextChild), node.parent?.syntaxNodeType == TupleTypeElementSyntax.self {
                    return true
                }
                nextChild = getTupleChild(nextChild)
            }
            return false
        }
    }
}
