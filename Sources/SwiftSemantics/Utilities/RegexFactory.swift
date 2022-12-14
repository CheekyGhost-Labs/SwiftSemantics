//
//  RegexFactory.swift
//  
//
//  Created by Cheeky Ghost Labson 2/6/2022.
//

import Foundation
import RegexBuilder

/// Class that holds regular expressions used for convenience assignments in memory to avoid re-creating each access.
enum RegularExpression: String, CaseIterable {
    case tupleDeclarationIsOptional

    // MARK: - Properties

    typealias RegexType = Regex<(Substring, Regex<Substring>.RegexOutput)>

    static var regexMap: [RegularExpression: RegexType] = [:]

    // MARK: - Init

    static func preBuild() {
        RegularExpression.allCases.forEach { _ = $0.buildPattern() }
    }

    func containsMatch(in input: String) -> Bool {
        let regex = buildPattern()
        let match = try? regex.firstMatch(in: input)
        return match != nil
    }

    func firstMatch(in input: String) -> String? {
        let regex = buildPattern()
        do {
            guard let result = try regex.firstMatch(in: input) else {
                print("`\(rawValue)` found no match")
                return nil
            }
            let resultSubstring: Substring = result.output.1
            return String(resultSubstring).trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            // print("`\(rawValue)` match failed: `\(error.localizedDescription)`")
            return nil
        }
    }

    private func buildPattern() -> RegexType {
        if let existing = Self.regexMap[self] {
            return existing
        }
        var regex: RegexType
        switch self {
        case .tupleDeclarationIsOptional:
            regex = Self.buildIsTupleDeclarationOptional()
        }
        Self.regexMap[self] = regex
        return regex
    }

    // MARK: - General

    private static func buildIsTupleDeclarationOptional() -> RegexType {
        do {
            return try Regex("(\\w{1}\\){1,}?$)|(\\){1,}\\?$)|(\\w{1}\\)\\?\\){1,}$)|(\\?{1}\\)\\?\\){1,}$)")
        } catch {
            fatalError("Error: Unable to generate regex")
        }
    }
}
