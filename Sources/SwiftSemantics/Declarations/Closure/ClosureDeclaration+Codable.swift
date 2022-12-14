//
//  ClosureDeclaration+Codable.swift
//  
//
//  Created by Michael O'Brien on 1/12/2022.
//

import Foundation

extension ClosureDeclaration {

    // MARK: - Codable

    enum CodingKeys: CodingKey {
        case inputs
        case outputs
        case isVoidInput
        case isVoidOutput
        case isEscaping
        case isAutoEscaping
        case inputType
        case outputType
        case declaration
        case isOptional
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
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
        // ClosureType
        self.isVoidInput = try container.decode(Bool.self, forKey: .isVoidInput)
        self.isVoidOutput = try container.decode(Bool.self, forKey: .isVoidOutput)
        self.isOptional = try container.decode(Bool.self, forKey: .isOptional)
        self.isEscaping = try container.decode(Bool.self, forKey: .isEscaping)
        self.isAutoEscaping = try container.decode(Bool.self, forKey: .isAutoEscaping)
        self.inputType = try container.decode(String.self, forKey: .inputType)
        self.outputType = try container.decode(String.self, forKey: .outputType)
        self.declaration = try container.decode(String.self, forKey: .declaration)
        let wrappedInputs = try container.decode(CodableParameters.self, forKey: .inputs)
        self.inputs = wrappedInputs.sortedElements
        let wrappedOutputs = try container.decode(CodableParameters.self, forKey: .outputs)
        self.outputs = wrappedOutputs.sortedElements
    }

    // MARK: - Conformnace: Hashable

    public func hash(into hasher: inout Hasher) {
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

    public static func == (lhs: ClosureDeclaration, rhs: ClosureDeclaration) -> Bool {
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
