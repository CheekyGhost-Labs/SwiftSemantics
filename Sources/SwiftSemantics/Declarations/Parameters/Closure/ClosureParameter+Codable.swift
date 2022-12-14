//
//  File.swift
//  
//
//  Created by Cheeky Ghost Labson 1/12/2022.
//

import Foundation

extension ClosureParameter {

    // MARK: - Codable

    enum CodingKeys: CodingKey {
        case attributes
        case defaultArgument
        case name
        case secondName
        case type
        case variadic
        case isOptional
        case isInOut
        case preferredName
        case typeWithoutAttributes
        case inputs
        case outputs
        case isVoidInput
        case isVoidOutput
        case isEscaping
        case isAutoEscaping
        case inputType
        case outputType
        case declaration
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // ParameterType
        try container.encode(attributes, forKey: .attributes)
        try container.encodeIfPresent(defaultArgument, forKey: .defaultArgument)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(secondName, forKey: .secondName)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encode(variadic, forKey: .variadic)
        try container.encode(isOptional, forKey: .isOptional)
        try container.encode(isInOut, forKey: .isInOut)
        try container.encodeIfPresent(preferredName, forKey: .preferredName)
        try container.encodeIfPresent(typeWithoutAttributes, forKey: .typeWithoutAttributes)
        // ClosureType
        try container.encode(isVoidInput, forKey: .isVoidInput)
        try container.encode(isVoidOutput, forKey: .isVoidOutput)
        try container.encode(isOptional, forKey: .isOptional)
        try container.encode(isEscaping, forKey: .isEscaping)
        try container.encode(isAutoEscaping, forKey: .isAutoEscaping)
        try container.encode(inputType, forKey: .inputType)
        try container.encode(outputType, forKey: .outputType)
        try container.encode(declaration, forKey: .declaration)
        var wrappedInputs = CodableParameters()
        for (index, item) in inputs.enumerated() { wrappedInputs.append(item, index: index) }
        try container.encode(wrappedInputs, forKey: .inputs)
        var wrappedOutputs = CodableParameters()
        for (index, item) in outputs.enumerated() { wrappedOutputs.append(item, index: index) }
        try container.encode(wrappedOutputs, forKey: .outputs)

    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        // ParameterType
        attributes = try container.decode([Attribute].self, forKey: .attributes)
        defaultArgument = try container.decodeIfPresent(String.self, forKey: .defaultArgument)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        secondName = try container.decodeIfPresent(String.self, forKey: .secondName)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        variadic = try container.decode(Bool.self, forKey: .variadic)
        isOptional = try container.decode(Bool.self, forKey: .isOptional)
        isInOut = try container.decode(Bool.self, forKey: .isInOut)
        preferredName = try container.decodeIfPresent(String.self, forKey: .preferredName)
        typeWithoutAttributes = try container.decodeIfPresent(String.self, forKey: .typeWithoutAttributes)
        // ClosureType
        isVoidInput = try container.decode(Bool.self, forKey: .isVoidInput)
        isVoidOutput = try container.decode(Bool.self, forKey: .isVoidOutput)
        isOptional = try container.decode(Bool.self, forKey: .isOptional)
        isEscaping = try container.decode(Bool.self, forKey: .isEscaping)
        isAutoEscaping = try container.decode(Bool.self, forKey: .isAutoEscaping)
        inputType = try container.decode(String.self, forKey: .inputType)
        outputType = try container.decode(String.self, forKey: .outputType)
        declaration = try container.decode(String.self, forKey: .declaration)
        let wrappedInputs = try container.decode(CodableParameters.self, forKey: .inputs)
        inputs = wrappedInputs.sortedElements
        let wrappedOutputs = try container.decode(CodableParameters.self, forKey: .inputs)
        outputs = wrappedOutputs.sortedElements
    }

    // MARK: - Conformnace: Hashable

    public func hash(into hasher: inout Hasher) {
        // ParameterType
        attributes.hash(into: &hasher)
        defaultArgument?.hash(into: &hasher)
        name?.hash(into: &hasher)
        secondName?.hash(into: &hasher)
        type?.hash(into: &hasher)
        variadic.hash(into: &hasher)
        isLabelOmitted.hash(into: &hasher)
        isOptional.hash(into: &hasher)
        isInOut.hash(into: &hasher)
        preferredName.hash(into: &hasher)
        typeWithoutAttributes?.hash(into: &hasher)
        // ClosureType
        isVoidInput.hash(into: &hasher)
        isVoidOutput.hash(into: &hasher)
        isOptional.hash(into: &hasher)
        isEscaping.hash(into: &hasher)
        isAutoEscaping.hash(into: &hasher)
        inputType.hash(into: &hasher)
        outputType.hash(into: &hasher)
        declaration.hash(into: &hasher)
        inputs.forEach {
            $0.hash(into: &hasher)
        }
        outputs.forEach {
            $0.hash(into: &hasher)
        }
    }

    // MARK: - Conformance: Equatable

    public static func == (lhs: ClosureParameter, rhs: ClosureParameter) -> Bool {
        // Parameter Type
        guard
            lhs.attributes == rhs.attributes,
            lhs.defaultArgument == rhs.defaultArgument,
            lhs.name == rhs.name,
            lhs.secondName == rhs.secondName,
            lhs.type == rhs.type,
            lhs.variadic == rhs.variadic,
            lhs.isLabelOmitted == rhs.isLabelOmitted,
            lhs.isOptional == rhs.isOptional,
            lhs.isInOut == rhs.isInOut,
            lhs.preferredName == rhs.preferredName,
            lhs.typeWithoutAttributes == rhs.typeWithoutAttributes
        else {
            return false
        }
        // Closure Type
        guard
            lhs.isVoidInput == rhs.isVoidInput,
            lhs.isVoidOutput == rhs.isVoidOutput,
            lhs.isOptional == rhs.isOptional,
            lhs.isEscaping == rhs.isEscaping,
            lhs.isAutoEscaping == rhs.isAutoEscaping,
            lhs.inputType == rhs.inputType,
            lhs.outputType == rhs.outputType,
            lhs.declaration == rhs.declaration,
            parametersEqual(lhs.inputs, rhs.inputs),
            parametersEqual(lhs.outputs, rhs.outputs)
        else {
            return false
        }
        return true
    }
}
