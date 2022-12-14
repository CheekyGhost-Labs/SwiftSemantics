//
//  TupleType+SwiftSyntax.swift
//
//
//  Created by Michael O'Brien on 1/12/2022.
//

import SwiftSyntax

extension TupleType {

    static func resolveFromFunctionParameterSyntax(_ node: FunctionParameterSyntax) -> TupleTypeSyntax? {
        // Closure Convenience
        var tupleNode: SwiftSyntax.Syntax?
        var nextToken: TokenSyntax? = node.firstToken
        while nextToken != nil {
            if nextToken?.parent?.syntaxNodeType == TupleTypeSyntax.self {
                tupleNode = nextToken?.parent?._syntaxNode
                break
            }
            nextToken = nextToken?.nextToken
        }
        guard let tupleNode = tupleNode else { return nil }
        return TupleTypeSyntax(tupleNode)
    }

    static func resolveElementListFromFunctionParameterSyntax(_ node: FunctionParameterSyntax) -> TupleTypeElementListSyntax? {
        // Closure Convenience
        var tupleNode: SwiftSyntax.Syntax?
        var nextToken: TokenSyntax? = node.firstToken
        while nextToken != nil {
            if nextToken?.parent?.syntaxNodeType == TupleTypeElementListSyntax.self {
                tupleNode = nextToken?.parent?._syntaxNode
                break
            }
            nextToken = nextToken?.nextToken
        }
        guard let tupleNode = tupleNode else { return nil }
        return TupleTypeElementListSyntax(tupleNode)
    }

    static func resolveFromVariableParameter(_ node: PatternBindingSyntax) -> TupleTypeSyntax? {
        // Closure Convenience
        var tupleDeclaration: SwiftSyntax.Syntax?
        var nextToken: TokenSyntax? = node.parent?.firstToken
        while nextToken != nil {
            if nextToken?.parent?.syntaxNodeType == TupleTypeSyntax.self {
                tupleDeclaration = nextToken?.parent?._syntaxNode
                break
            }
            nextToken = nextToken?.nextToken
        }
        guard let tupleNode = tupleDeclaration else { return nil }
        return TupleTypeSyntax(tupleNode)
    }

    static func resolveElementListFromVariableParameter(_ node: PatternBindingSyntax) -> TupleTypeElementListSyntax? {
        // Closure Convenience
        var tupleDeclaration: SwiftSyntax.Syntax?
        var nextToken: TokenSyntax? = node.parent?.firstToken
        while nextToken != nil {
            if nextToken?.parent?.syntaxNodeType == TupleTypeElementListSyntax.self {
                tupleDeclaration = nextToken?.parent?._syntaxNode
                break
            }
            nextToken = nextToken?.nextToken
        }
        guard let tupleNode = tupleDeclaration else { return nil }
        return TupleTypeElementListSyntax(tupleNode)
    }
}
