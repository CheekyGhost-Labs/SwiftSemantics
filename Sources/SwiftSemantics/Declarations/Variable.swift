import Foundation
import SwiftSyntax

/// A declaration for a property or a top-level variable or constant.
public struct Variable: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"let"` or `"var"`).
    public let keyword: String

    /// The name of the property or top-level variable or constant.
    public let name: String

    /// The type annotation for the declaration, if any.
    public let typeAnnotation: String?

    /// The initialized value for the declaration, if any.
    public let initializedValue: String?

    /// The variable or property accessors.
    public let accessors: [Accessor]

    /// The parent entity that owns the variable.
    public let parent: String?

    /// A computed variable or computed property accessor.
    public struct Accessor: Hashable, Codable {
        /// The kind of accessor (`get` or `set`).
        public enum Kind: String, Hashable, Codable {
            /// A getter that returns a value.
            case get

            /// A setter that sets a value.
            case set
        }

        /// The accessor attributes.
        public let attributes: [Attribute]

        /// The accessor modifiers.
        public let modifier: Modifier?

        /// The kind of accessor.
        public let kind: Kind?
    }

    // MARK: - Convenience

    /// Will return any modifiers joined by a whitespace and then the `keyword`
    public let modifiersWithKeyword: String

    /// Bool whether the variable has a setter available
    public let hasSetter: Bool

    /// Will return a `Bool` flag indicating if the type annotation contains the optional indicator `?`
    public let isOptional: Bool

    /// Will return `true` when the `type` is a closure.
    public let isClosure: Bool

    /// WIll return the input `typeAnnotation` for the closure. Returns an empty string if no input is found.
    public let closureInput: String

    /// WIll return the result `typeAnnotation` for the closure. Returns an empty string if no result is found.
    public let closureResult: String

    /// WIll return`true` if the `typeAnnotation` is a closure and the input is a void block. i.e `(Void) -> String/ (()) -> String`.
    public let isClosureInputVoid: Bool

    /// WIll return`true` if the `typeAnnotation` is a closure and the input is a void block. i.e `() -> (Void)/() -> (())`.
    public let isClosureResultVoid: Bool

}

// MARK: - ExpressibleBySyntax

extension Variable: ExpressibleBySyntax {
    /**
     Creates and returns variables from a variable declaration,
     which may contain one or more pattern bindings,
     such as `let x: Int = 1, y: Int = 2`.
     */
    public static func variables(from node: VariableDeclSyntax) -> [Variable] {
        return node.bindings.compactMap { Variable($0) }
    }

    /// Creates an instance initialized with the given syntax node.
    public init?(_ node: PatternBindingSyntax) {
        guard let parent = node.context as? VariableDeclSyntax else {
            preconditionFailure("PatternBindingSyntax should be contained within VariableDeclSyntax")
            return nil
        }

        attributes = parent.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
        modifiers = parent.modifiers?.map { Modifier($0) } ?? []
        keyword = parent.letOrVarKeyword.text.trimmed
        name = node.pattern.description.trimmed
        typeAnnotation = node.typeAnnotation?.type.description.trimmed
        initializedValue = node.initializer?.value.description.trimmed
        accessors = Accessor.accessors(from: node.accessor?.as(AccessorBlockSyntax.self))
        // Assign parent
        self.parent = node.resolveParentType()
        self.hasSetter = accessors.contains(where: { $0.kind == .set })
        if let annotation = typeAnnotation {
            self.isOptional = annotation.last == "?"
        } else {
            self.isOptional = false
        }
        // Modifier string
        let modifiers: [String] = modifiers.map { $0.name }
        if modifiers.isEmpty {
            self.modifiersWithKeyword = keyword
        } else {
            self.modifiersWithKeyword = "\(modifiers.joined(separator: " ")) \(keyword)"
        }
        // Closure convenience
        let type = typeAnnotation ?? ""
        let typeRange = NSRange(location: 0, length: type.count)
        // isClosure
        if let regex = try? RegexFactory.shared.isClosure() {
            self.isClosure = (regex.firstMatch(in: type, range: typeRange) != nil)
        } else {
            self.isClosure = false
        }
        guard isClosure else {
            self.closureInput = ""
            self.closureResult = ""
            self.isClosureInputVoid = false
            self.isClosureResultVoid = false
            return
        }
        let closureComponents = type.components(separatedBy: "->").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard closureComponents.count == 2 else {
            self.closureInput = ""
            self.closureResult = ""
            self.isClosureInputVoid = false
            self.isClosureResultVoid = false
            return
        }
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
        let voids: [String] = ["(())","((Void)","(Void)"]
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

extension Variable.Accessor: ExpressibleBySyntax {
    public static func accessors(from node: AccessorBlockSyntax?) -> [Variable.Accessor] {
        guard let node = node else { return [] }
        return node.accessors.compactMap { Variable.Accessor($0) }
    }

    public init?(_ node: AccessorDeclSyntax) {
        let rawValue = node.accessorKind.text.trimmed
        if rawValue.isEmpty {
            self.kind = nil
        } else if let kind = Kind(rawValue: rawValue) {
            self.kind = kind
        } else {
            return nil
        }

        attributes = node.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
        modifier = node.modifier.map { Modifier($0) }
    }
}

// MARK: - CustomStringConvertible

extension Variable: CustomStringConvertible {
    public var description: String {
        switch (self.typeAnnotation, self.initializedValue) {
        case let (typeAnnotation?, initializedValue?):
            return "\(keyword) \(name): \(typeAnnotation) = \(initializedValue)"
        case let (typeAnnotation?, _):
            return "\(keyword) \(name): \(typeAnnotation)"
        case let (_, initializedValue?):
            return "\(keyword) \(name) = \(initializedValue)"
        default:
            return "\(keyword) \(name)"
        }
    }
}

