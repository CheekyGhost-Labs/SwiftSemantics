//
//  File.swift
//  
//
//  Created by Michael O'Brien on 1/12/2022.
//

import SwiftSyntax

public struct TupleDeclaration: TupleType, Codable, Hashable, Equatable, CustomStringConvertible {

    // MARK: - Properties: TupleType

    internal(set) public var arguments: [any ParameterType] = []

    internal(set) public var isOptional: Bool = false

    // MARK: - Lifecycle

    public init(_ node: TupleTypeSyntax) {
        initializeArguments(node.elements)
        // isOptional
        var nextParent = node.parent
        while nextParent != nil {
            if nextParent?.syntaxNodeType == OptionalTypeSyntax.self {
                isOptional = true
                break
            }
            nextParent = nextParent?.parent
        }
    }

    public init(_ node: TupleTypeElementListSyntax) {
        initializeArguments(node)
        // isOptional
        var nextParent = node.parent
        while nextParent != nil {
            if nextParent?.syntaxNodeType == OptionalTypeSyntax.self {
                isOptional = true
                break
            }
            nextParent = nextParent?.parent
        }
    }

    init?(_ parameter: TupleParameter?) {
        guard let parameter = parameter else { return nil }
        arguments = parameter.arguments
    }

    // MARK: - Lifecycle: Helpers

    mutating func initializeArguments(_ node: TupleTypeElementListSyntax) {
        arguments = TupleArgumentCollector.collect(node)
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        var description: String = "("
        description += arguments.map(\.description).joined(separator: ", ")
        description += ")"
        return description
    }
}
