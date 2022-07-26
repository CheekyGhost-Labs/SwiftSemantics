//
//  RegexFactory.swift
//  
//
//  Created by Michael O'Brien on 2/6/2022.
//

import Foundation

/// Class that holds regular expressions used for convenience assignments in memory to avoid re-creating each access.
class RegexFactory {

    // MARK: - Properties

    static var shared: RegexFactory = RegexFactory()

    var regexMap: [String: NSRegularExpression] = [:]

    // MARK: - Init

    init() {
        _ = try? isClosure()
        _ = try? closureInput()
        _ = try? closureEmptyInput()
        _ = try? closureVoidInput()
        _ = try? closureVoidResult()
    }

    // MARK: - Helpers

    func regexForPattern(_ pattern: String) throws -> NSRegularExpression {
        if let existing = regexMap[pattern] {
            return existing
        }
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        regexMap[pattern] = regex
        return regex
    }

    // MARK: - Parameter Closures

    func isClosure() throws -> NSRegularExpression {
        return try regexForPattern("\\)\\s{0,}\\-\\>\\s{0,}((\\(.*\\))|Void|[\\w\\?\\!]+\\){0,1})")
    }

    func closureInput() throws -> NSRegularExpression {
        return try regexForPattern("\\({0,}(\\(\\s{0,}\\)|\\(.{1,}\\))(?=\\s{0,}\\-\\>\\s{0,})")
    }

    func closureEmptyInput() throws -> NSRegularExpression {
        return try regexForPattern("\\((\\s{0,})\\)\\s{0,}\\-\\>")
    }

    func closureVoidInput() throws -> NSRegularExpression {
        return try regexForPattern("(^\\(\\({0,}Void|^\\(\\(\\)\\){0,}|^Void)[\\s\\?\\!]{0,}(?m)")
    }

    func closureVoidResult() throws -> NSRegularExpression {
        return try regexForPattern("(\\((\\s{0,}|\\s{0,}Void{0,})\\)|Void)[\\s\\?\\!]{0,}(?m)")
    }
}
