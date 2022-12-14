//
//  File.swift
//  
//
//  Created by Michael O'Brien on 1/12/2022.
//

import Foundation

extension Initializer {

    enum CodingKeys: CodingKey {
        case attributes
        case modifiers
        case keyword
        case optional
        case genericParameters
        case parameters
        case throwsOrRethrowsKeyword
        case genericRequirements
        case parent
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(attributes, forKey: .attributes)
        try container.encode(modifiers, forKey: .modifiers)
        try container.encode(keyword, forKey: .keyword)
        try container.encode(self.optional, forKey: .optional)
        try container.encode(genericParameters, forKey: .genericParameters)
        try container.encodeIfPresent(throwsOrRethrowsKeyword, forKey: .throwsOrRethrowsKeyword)
        try container.encode(genericRequirements, forKey: .genericRequirements)
        try container.encode(parent, forKey: .parent)
        var wrappedParameters = CodableParameters()
        for (index, item) in parameters.enumerated() {
            wrappedParameters.append(item, index: index)
        }
        try container.encode(wrappedParameters, forKey: .parameters)
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        attributes = try container.decode([Attribute].self, forKey: .attributes)
        modifiers = try container.decode([Modifier].self, forKey: .modifiers)
        keyword = try container.decode(String.self, forKey: .keyword)
        self.optional = try container.decode(Bool.self, forKey: .optional)
        genericParameters = try container.decode([GenericParameter].self, forKey: .genericParameters)
        throwsOrRethrowsKeyword = try container.decodeIfPresent(String.self, forKey: .throwsOrRethrowsKeyword)
        genericRequirements = try container.decode([GenericRequirement].self, forKey: .genericRequirements)
        parent = try container.decode(Parent.self, forKey: .parent)
        let wrappedParameters = try container.decode(CodableParameters.self, forKey: .parameters)
        parameters = wrappedParameters.sortedElements
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        attributes.hash(into: &hasher)
        modifiers.hash(into: &hasher)
        keyword.hash(into: &hasher)
        self.optional.hash(into: &hasher)
        genericParameters.hash(into: &hasher)
        throwsOrRethrowsKeyword?.hash(into: &hasher)
        genericRequirements.hash(into: &hasher)
        parent?.hash(into: &hasher)
        parameters.forEach {
            $0.hash(into: &hasher)
        }
    }

    // MARK: - Equatable

    public static func == (lhs: Initializer, rhs: Initializer) -> Bool {
        guard
            lhs.attributes == rhs.attributes,
            lhs.modifiers == rhs.modifiers,
            lhs.keyword == rhs.keyword,
            lhs.optional == rhs.optional,
            lhs.genericParameters == rhs.genericParameters,
            lhs.throwsOrRethrowsKeyword == rhs.throwsOrRethrowsKeyword,
            lhs.genericRequirements == rhs.genericRequirements,
            lhs.parent == rhs.parent,
            parametersEqual(lhs.parameters, rhs.parameters)
        else {
            return false
        }
        return true
    }
}
