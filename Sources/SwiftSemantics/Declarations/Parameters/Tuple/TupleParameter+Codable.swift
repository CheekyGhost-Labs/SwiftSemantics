//
//  TupleParameter+Conformance.swift
//  
//
//  Created by Cheeky Ghost Labson 1/12/2022.
//

import Foundation

extension TupleParameter {

    enum CodingKeys: CodingKey {
        case attributes
        case defaultArgument
        case name
        case secondName
        case type
        case variadic
        case isOptional
        case isInOut
        case isLabelOmitted
        case preferredName
        case typeWithoutAttributes
        case arguments
    }

    // MARK: - Conformance: Codable

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(attributes, forKey: .attributes)
        try container.encodeIfPresent(defaultArgument, forKey: .defaultArgument)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(secondName, forKey: .secondName)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encode(variadic, forKey: .variadic)
        try container.encode(isLabelOmitted, forKey: .isLabelOmitted)
        try container.encode(isOptional, forKey: .isOptional)
        try container.encode(isInOut, forKey: .isInOut)
        try container.encodeIfPresent(preferredName, forKey: .preferredName)
        try container.encodeIfPresent(typeWithoutAttributes, forKey: .typeWithoutAttributes)
        // Elements
        var wrapper = CodableParameters()
        for (index, item) in arguments.enumerated() {
            wrapper.append(item, index: index)
        }
        try container.encode(wrapper, forKey: .arguments)
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
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
        let wrappedElements = try container.decode(CodableParameters.self, forKey: .arguments)
        arguments = wrappedElements.sortedElements
    }

    // MARK: - Conformance: Hashable

    public func hash(into hasher: inout Hasher) {
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
        arguments.forEach {
            $0.hash(into: &hasher)
        }
    }

    // MARK: - Conformance: Equatable

    public static func == (lhs: TupleParameter, rhs: TupleParameter) -> Bool {
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
            lhs.typeWithoutAttributes == rhs.typeWithoutAttributes,
            parametersEqual(lhs.arguments, rhs.arguments)
        else {
            return false
        }
        return true
    }
}
