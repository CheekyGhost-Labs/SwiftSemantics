//
//  File.swift
//  
//
//  Created by Cheeky Ghost Labson 1/12/2022.
//

import Foundation
import SwiftSyntax

extension ClosureType {

    func belongsToFunction(_ node: FunctionTypeSyntax) -> Bool {
        var parent = node.parent
        while parent != nil {
            if parent?.syntaxNodeType == FunctionParameterListSyntax.self {
                return true
            }
            parent = parent?.parent
        }
        return false
    }

    func belongsToVariable(_ node: FunctionTypeSyntax) -> Bool {
        var parent = node.parent
        while parent != nil {
            if parent?.syntaxNodeType == VariableDeclSyntax.self {
                return true
            }
            parent = parent?.parent
        }
        parent = parent?.parent
        return false
    }

    func belongsToTypeAlias(_ node: FunctionTypeSyntax) -> Bool {
        var parent = node.parent
        while parent != nil {
            if parent?.syntaxNodeType == TypealiasDeclSyntax.self {
                return true
            }
            parent = parent?.parent
        }
        parent = parent?.parent
        return false
    }
}
