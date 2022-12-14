//
//  File.swift
//  
//
//  Created by Michael O'Brien on 1/12/2022.
//

import Foundation

extension TupleDeclaration {

    // MARK: - Codable

    enum CodingKeys: CodingKey {
        case arguments
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var wrappedArguments = CodableParameters()
        for (index, item) in arguments.enumerated() { wrappedArguments.append(item, index: index) }
        try container.encode(wrappedArguments, forKey: .arguments)

    }

    public init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        // ClosureType
        let wrappedArguments = try container.decode(CodableParameters.self, forKey: .arguments)
        arguments = wrappedArguments.sortedElements
    }

    // MARK: - Conformnace: Hashable

    public func hash(into hasher: inout Hasher) {
        arguments.forEach {
            $0.hash(into: &hasher)
        }
    }

    // MARK: - Conformance: Equatable

    public static func == (lhs: TupleDeclaration, rhs: TupleDeclaration) -> Bool {
        parametersEqual(lhs.arguments, rhs.arguments)
    }
}
