//
//  ClosureType.swift
//
//
//  Created by Cheeky Ghost Labson 1/12/2022.
//

import Foundation
import SwiftSyntax

public protocol ClosureType {

    typealias OutputDetails = (elements: [any ParameterType], type: String, isVoid: Bool)

    /// WIll return the closure input elements from the input `typeAnnotation` for the closure.
    var inputs: [any ParameterType] { get }

    /// WIll return the closure output elements from the input `typeAnnotation` for the closure.
    var outputs: [any ParameterType] { get }

    /// WIll return`true` if the `typeAnnotation` is a closure and the input is a void block. i.e `(Void) -> String/ (()) -> String`.
    var isVoidInput: Bool { get }

    /// WIll return`true` if the `typeAnnotation` is a closure and the input is a void block. i.e `() -> (Void)/() -> (())`.
    var isVoidOutput: Bool { get }

    /// Bool whether the closure is an optional.
    var isOptional: Bool { get }

    /// Bool whether the closure has the `@escaping` attribute.
    /// **Note:** This separate from the `isAutoEscaping` proeprty as you may want to know whether something has the attribute or not.
    var isEscaping: Bool { get }

    /// Bool whether the closure is auto escaping.
    /// This would be `true` when the closure itself is optional as swift expects them to be auto-escaping.
    var isAutoEscaping: Bool { get }

    /// The full input type string
    var inputType: String { get }

    /// The full return type string
    var outputType: String { get }

    /// The full declaration string.
    var declaration: String { get }

    // MARK: - Properties: Convenience

    /// WIll return the closure input  `typeAnnotation` for the closure.
    var rawInput: String { get }

    /// WIll return the result `typeAnnotation` for the closure. Returns an empty string if no result is found.
    var rawOutput: String { get }
}

extension ClosureType {

    public var rawInput: String {
        guard !inputs.isEmpty else { return inputType }
        let joined = inputs.map(\.description).joined(separator: ",")
        return "(\(joined))"
    }

    public var rawOutput: String {
        guard !outputs.isEmpty else { return outputType }
        let joined = outputs.map(\.description).joined(separator: ",")
        return "(\(joined))"
    }
}
