//
//  File.swift
//  
//
//  Created by Cheeky Ghost Labson 1/12/2022.
//

import Foundation
import SwiftSyntax

public struct ClosureParameter: ParameterType, ClosureType {

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

    // MARK: - Properties: ClosureType

    internal(set) public var inputs: [any ParameterType] = []

    internal(set) public var outputs: [any ParameterType] = []

    internal(set) public var isVoidInput: Bool = false

    internal(set) public var isVoidOutput: Bool = false
    
    internal(set) public var isEscaping: Bool = false
    
    internal(set) public var isAutoEscaping: Bool = false
    
    internal(set) public var inputType: String = ""

    internal(set) public var outputType: String = ""

    internal(set) public var declaration: String = ""

    // MARK: - Lifecycle

    public init(_ node: FunctionTypeSyntax) {
        type = node.description
        typeWithoutAttributes = Utils.stripAttributes(from: node.description)
        declaration = node.description.trimmed
        let inputParameters = ClosureArgumentCollector.collectInputs(node)
        inputs = inputParameters.parameters
        inputType = inputParameters.type
        isVoidInput = inputParameters.isVoid
        let outputParameters = ClosureArgumentCollector.collectOutputs(node)
        outputs = outputParameters.parameters
        outputType = outputParameters.type
        isVoidOutput = outputParameters.isVoid
        // Assign parameter values if parent is present
        if let parent = resolveParentFunctionSyntax(from: node._syntaxNode) {
            assignParameterPropertiesFromFunctionParent(parent)
        }
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
        // AutoEscaping
        isAutoEscaping = isOptional
        // Escaping
        guard !attributes.isEmpty else { return }
        let flattened: [String] = attributes.map(\.name)
        isEscaping = flattened.contains("escaping")
    }

    // MARK: - Lifecycle Utilities

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
        isInOut = node.type?.tokens.contains(where: { $0.tokenKind == .inoutKeyword }) ?? false
        isOptional = Utils.isTypeOptional(type)
        preferredName = Utils.getPreferredName(firstName: name, secondName: secondName, labelOmitted: Utils.isLabelOmitted(name))
        typeWithoutAttributes = Utils.stripAttributes(from: type)
    }
}
