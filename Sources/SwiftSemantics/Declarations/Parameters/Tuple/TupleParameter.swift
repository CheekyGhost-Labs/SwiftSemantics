//
//  TupleParameter.swift
//  
//
//  Created by Cheeky Ghost Labson 1/12/2022.
//

import Foundation
import SwiftSyntax

public struct TupleParameter: ParameterType, TupleType {

    // MARK: Conformance: ParameterType

    internal(set) public var attributes: [Attribute] = []

    internal(set) public var defaultArgument: String?

    internal(set) public var name: String?

    internal(set) public var secondName: String?

    internal(set) public var type: String?

    internal(set) public var variadic: Bool = false

    internal(set) public var isOptional: Bool = false

    internal(set) public var isInOut: Bool = false

    internal(set) public var preferredName: String?

    internal(set) public var typeWithoutAttributes: String?

    // MARK: - Properties: TupleType

    internal(set) public var arguments: [any ParameterType] = []

    // MARK: - Lifecycle

    public init(_ node: TupleTypeSyntax) {
        self.arguments = TupleArgumentCollector.collect(node.elements)
        type = node.description
        typeWithoutAttributes = node.description
        // Optional
        var nextParent = node.parent
        while nextParent != nil {
            if nextParent?.syntaxNodeType == OptionalTypeSyntax.self {
                isOptional = true
                break
            } else if nextParent?.syntaxNodeType == FunctionTypeSyntax.self {
                break
            }
            nextParent = nextParent?.parent
        }
        typeWithoutAttributes = Utils.stripAttributes(from: type)
        // The tuple might be an element within a larger tuple, or simply a declaration type within a parameter set
        // If a parent `TupleTypeElementSyntax` can be resolved then it has parameter properties.
        if let parent = resolveParentElementFromSyntax(node) {
            name = parent.name?.text
            secondName = parent.secondName?.text
            preferredName = Utils.getPreferredName(firstName: name, secondName: secondName, labelOmitted: Utils.isLabelOmitted(name))
            variadic = parent.ellipsis != nil
            defaultArgument = nil
            isInOut = parent.inOut != nil
        }
    }
    
    public init(_ node: TupleTypeElementListSyntax) {
        arguments = TupleArgumentCollector.collect(node)
        type = node.description
        typeWithoutAttributes = node.description
        isOptional = Utils.isTypeOptional(type)
        typeWithoutAttributes = Utils.stripAttributes(from: type)
    }

    // MARK: - Lifecycle: Helpers

    func resolveParentElementFromSyntax(_ node: TupleTypeSyntax) -> TupleTypeElementSyntax? {
        guard var parent = node.parent else { return nil }
        if parent.syntaxNodeType == OptionalTypeSyntax.self, let nextParent = parent.parent {
            parent = nextParent
        }
        return TupleTypeElementSyntax(parent._syntaxNode)
    }
}
