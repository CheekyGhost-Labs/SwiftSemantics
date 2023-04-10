import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

/// A function declaration.
public struct Function: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"func"`).
    public let keyword: String

    /// The function identifier.
    public let identifier: String

    /// The function signature.
    public let signature: Signature

    /**
     The generic parameters for the declaration.

     For example,
     the following declaration of function `f`
     has a single generic parameter
     whose `identifier` is `"T"` and `type` is `"Equatable"`:

     ```swift
     func f<T: Equatable>(value: T) {}
     ```
     */
    public let genericParameters: [GenericParameter]

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following declaration of function `f`
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Hashable"`:

     ```swift
     func f<T>(value: T) where T: Hashable {}
     ```
     */
    public let genericRequirements: [GenericRequirement]

    /// Whether the function is an operator.
    public var isOperator: Bool {
        return Operator.Kind(modifiers) != nil || Operator.isValidIdentifier(identifier)
    }

    /// A function signature.
    public struct Signature: Hashable, Codable {

        // MARK: - Properties

        /// The function inputs.
        public let input: [any ParameterType]

        /// The function output, if any.
        public let output: String?

        /// The `throws` or `rethrows` keyword, if any.
        public let throwsOrRethrowsKeyword: String?

    }

    /// The parent entity that owns the function.
    public let parent: Parent?

    /// The location the function declaration starts on.
    public internal(set) var startLocation: DeclarationLocation = .empty()

    /// The location the declaration closes/ends on.
    public internal(set) var endLocation: DeclarationLocation = .empty()
}

// MARK: - ExpressibleBySyntax

extension Function: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: FunctionDeclSyntax) {
        attributes = AttributesCollector.collect(node)
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.funcKeyword.text.trimmed
        identifier = node.identifier.text.trimmed
        signature = Signature(node.signature)
        genericParameters = node.genericParameterClause?.genericParameterList.map { GenericParameter($0) } ?? []
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
        // Assign parent
        parent = Parent(node.resolveRootParent())
    }
}

extension Function.Signature: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: FunctionSignatureSyntax) {
        input = FunctionParameterCollector.collect(node.input.parameterList)
        output = node.output?.returnType.description.trimmed
        throwsOrRethrowsKeyword = node.throwsOrRethrowsKeyword?.description.trimmed
    }
}

// MARK: - CustomStringConvertible

extension Function: CustomStringConvertible {
    public var description: String {
        var description = (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, identifier]
        ).joined(separator: " ")

        if !genericParameters.isEmpty {
            description += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        description += signature.description

        if !genericRequirements.isEmpty {
            description += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return description
    }
}

extension Function.Signature: CustomStringConvertible {
    public var description: String {
        var description = "(\(input.map { $0.description }.joined(separator: ", ")))"
        if let throwsOrRethrowsKeyword = throwsOrRethrowsKeyword {
            description += " \(throwsOrRethrowsKeyword)"
        }

        if let output = output {
            description += " -> \(output)"
        }

        return description
    }
}
