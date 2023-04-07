//
//  ClosureDeclaration.swift
//  
//
//  Created by Michael O'Brien on 1/12/2022.
//

import SwiftSyntax

public struct ClosureDeclaration: ClosureType, Codable, Hashable, Equatable, CustomStringConvertible {

    // MARK: - Properties: ClosureType

    internal(set) public var inputs: [any ParameterType] = []

    internal(set) public var outputs: [any ParameterType] = []

    internal(set) public var isVoidInput: Bool = false

    internal(set) public var isVoidOutput: Bool = false

    internal(set) public var isOptional: Bool = false

    internal(set) public var isEscaping: Bool = false
    
    internal(set) public var isAutoEscaping: Bool = false

    internal(set) public var inputType: String = ""

    internal(set) public var outputType: String = ""

    internal(set) public var declaration: String = ""

    public var description: String { declaration }

    // MARK: - Lifecycle

    public init(_ node: FunctionTypeSyntax) {
        declaration = node.description.trimmed
        let components = resolveClosureComponents(from: node)
        let inputParameters = ClosureInputParameterCollector.collect(node)
        inputs = inputParameters.parameters
        inputType = components.input
        isVoidInput = inputParameters.isVoid
        let outputParameters = ClosureOutputParameterCollector.collect(node)
        outputs = outputParameters.parameters
        outputType = components.output
        isVoidOutput = outputParameters.isVoid
        // isOptional
        var nextParent = node.parent
        while nextParent != nil {
            if nextParent?.syntaxNodeType == OptionalTypeSyntax.self {
                isOptional = true
                break
            }
            nextParent = nextParent?.parent
        }
        isAutoEscaping = isOptional
        // Check if is attributed
        guard let parent = node.parent, parent.syntaxNodeType == AttributedTypeSyntax.self else {
            isEscaping = false
            return
        }
        // Assess if escaping
        let attributes = AttributesCollector.collect(parent)
        let flattened: [String] = attributes.map(\.name)
        isEscaping = flattened.contains("escaping")
    }

    public init(_ parameter: ClosureParameter) {
        declaration = parameter.description
        inputs = parameter.inputs
        inputType = parameter.inputType
        isVoidInput = parameter.isVoidInput
        outputs = parameter.outputs
        outputType = parameter.outputType
        isVoidOutput = parameter.isVoidOutput
        isOptional = parameter.isOptional
        isAutoEscaping = parameter.isAutoEscaping
        isEscaping = parameter.isEscaping
    }

    func resolveClosureComponents(from node: FunctionTypeSyntax) -> (input: String, output: String) {
        // Note: Until can drop macOS 13 will just use components separated + hacky bs to resolve these properly
        let description = node.children(viewMode: .fixedUp).map(\.description).joined()
        let components = description.components(separatedBy: "->")
        let input = (components.first ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let outputSplit = "\(input) ->"
        let output = description.dropFirst(outputSplit.count).trimmed
        return (input, output)
    }
}
