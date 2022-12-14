//
//  File.swift
//  
//
//  Created by Michael O'Brien on 1/12/2022.
//

import Foundation

extension Function.Signature {

    enum CodingKeys: CodingKey {
        case input
        case output
        case throwsOrRethrowsKeyword
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(output, forKey: .output)
        try container.encodeIfPresent(throwsOrRethrowsKeyword, forKey: .throwsOrRethrowsKeyword)
        var wrappedParameters = CodableParameters()
        for (index, item) in input.enumerated() {
            wrappedParameters.append(item, index: index)
        }
        try container.encode(wrappedParameters, forKey: .input)
    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        output = try container.decodeIfPresent(String.self, forKey: .output)
        throwsOrRethrowsKeyword = try container.decodeIfPresent(String.self, forKey: .throwsOrRethrowsKeyword)
        let wrappedParameters = try container.decode(CodableParameters.self, forKey: .input)
        input = wrappedParameters.sortedElements
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        output?.hash(into: &hasher)
        throwsOrRethrowsKeyword?.hash(into: &hasher)
        input.forEach {
            $0.hash(into: &hasher)
        }
    }

    // MARK: - Equatable

    public static func == (lhs: Function.Signature, rhs: Function.Signature) -> Bool {
        guard lhs.output == rhs.output, lhs.throwsOrRethrowsKeyword == rhs.throwsOrRethrowsKeyword else { return false }
        return parametersEqual(lhs.input, rhs.input)
    }
}
