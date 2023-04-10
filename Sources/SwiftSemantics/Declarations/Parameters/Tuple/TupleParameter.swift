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
        // Assign parameter values if parent is present
        if let parent = resolveParentFunctionSyntax(from: node._syntaxNode) {
            assignParameterPropertiesFromFunctionParent(parent)
        } else if let parent = resolveParentElementFromSyntax(node) {
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
        if let parent = resolveParentFunctionSyntax(from: node._syntaxNode) {
            assignParameterPropertiesFromFunctionParent(parent)
        }
    }

    // MARK: - Lifecycle: Helpers

    func resolveParentElementFromSyntax(_ node: TupleTypeSyntax) -> TupleTypeElementSyntax? {
        guard var parent = node.parent else { return nil }
        if parent.syntaxNodeType == OptionalTypeSyntax.self, let nextParent = parent.parent {
            parent = nextParent
        }
        return TupleTypeElementSyntax(parent._syntaxNode)
    }

    func resolveParentFunctionSyntax(from node: Syntax) -> FunctionParameterSyntax? {
        var parentNode = node.parent
        while parentNode != nil {
            if let parent = parentNode, parent.syntaxNodeType == FunctionParameterSyntax.self {
                return FunctionParameterSyntax(parent._syntaxNode)
            }
            parentNode = parentNode?.parent
        }
        return nil
    }

    mutating func assignParameterPropertiesFromFunctionParent(_ node: FunctionParameterSyntax) {
        // If a parent element can be found (holding parameter properties and attributes etc) - assign the values
        attributes = AttributesCollector.collect(node)
        name = node.firstName?.text.trimmed
        secondName = node.secondName?.text.trimmed
        type = node.type?.description.trimmed
        variadic = node.ellipsis != nil
        defaultArgument = node.defaultArgument?.value.description.trimmed
        isInOut = node.type?.tokens(viewMode: .fixedUp).contains(where: { $0.tokenKind == .inoutKeyword }) ?? false
        isOptional = Utils.isTypeOptional(type)
        preferredName = Utils.getPreferredName(firstName: name, secondName: secondName, labelOmitted: Utils.isLabelOmitted(name))
        typeWithoutAttributes = Utils.stripAttributes(from: type)
    }
}
