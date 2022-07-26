//
//  ClosureUtility.swift
//  
//
//  Created by Michael O'Brien on 23/6/2022.
//

import Foundation

/// Convenience struct to handle parsing a type and determining if it is a closure. If the type is a closure it will assign various convenience properties.
struct ClosureDetails {

    // MARK: - Properties

    /// Will return `true` when the `type` is a closure.
    private(set) var isClosure: Bool = false

    /// WIll return the input `typeAnnotation` for the closure. Returns an empty string if no input is found.
    private(set) var closureInput: String = ""

    /// WIll return the result `typeAnnotation` for the closure. Returns an empty string if no result is found.
    private(set) var closureResult: String = ""

    /// WIll return`true` if the `typeAnnotation` is a closure and the input is a void block. i.e `(Void) -> String/ (()) -> String`.
    private(set) var isClosureInputVoid: Bool = false

    /// WIll return`true` if the `typeAnnotation` is a closure and the input is a void block. i.e `() -> (Void)/() -> (())`.
    private(set) var isClosureResultVoid: Bool = false

    // MARK: - Lifecycle

    init?(typeString: String?) {
        guard let type = typeString else { return nil }
        // Closure convenience
        let typeRange = NSRange(location: 0, length: type.count)
        // isClosure
        var isTypeClosure: Bool = false
        if let regex = try? RegexFactory.shared.isClosure() {
            isTypeClosure = (regex.firstMatch(in: type, range: typeRange) != nil)
        }
        guard isTypeClosure else { return nil }
        self.isClosure = true
        // Parse and assign
        let closureComponents = type.components(separatedBy: "->").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard closureComponents.count == 2 else { return }
        // Parse and assign
        let rawInput = closureComponents[0]
        var input = rawInput
        // Closure Input
        if input.starts(with: "(("), input.hasSuffix("))") {
            let rangeStart = String.Index(utf16Offset: 1, in: input)
            let rangeEnd = String.Index(utf16Offset: input.count - 2, in: input)
            input = String(input[rangeStart...rangeEnd])
        } else if input.starts(with: "((("), !input.hasSuffix("))") {
            let rangeStart = String.Index(utf16Offset: 1, in: input)
            input = String(input[rangeStart...])
        } else if input.starts(with: "(("), !input.hasSuffix("))") {
            let rangeStart = String.Index(utf16Offset: 1, in: input)
            input = String(input[rangeStart...])
        }
        self.closureInput = input
        // Is input void
        let voids: [String] = ["(())","((Void)","((Void))","(Void)"]
        let cleanInput = rawInput.replacingOccurrences(of: " ", with: "")
        self.isClosureInputVoid = voids.contains(cleanInput)
        // Closure Output
        var output = closureComponents[1]
        if output.hasSuffix("))"), !output.starts(with: "(("), output.count > 1 {
            let rangeEnd = String.Index(utf16Offset: output.count - 2, in: output)
            output = String(output[...rangeEnd])
        } else if output.hasSuffix(")"), !output.starts(with: "("), output.count > 1 {
            let rangeEnd = String.Index(utf16Offset: output.count - 2, in: output)
            output = String(output[...rangeEnd])
        }
        self.closureResult = output
        // Is result void
        if let regex = try? RegexFactory.shared.closureVoidResult() {
            let outputRange = NSRange(location: 0, length: output.count)
            self.isClosureResultVoid = (regex.firstMatch(in: output, range: outputRange) != nil)
        } else {
            self.isClosureResultVoid = false
        }
    }
}
