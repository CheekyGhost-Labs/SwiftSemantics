import SwiftSyntax

/// A protocol declaration.
public struct Protocol: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"protocol"`).
    public let keyword: String

    /// The protocol name.
    public let name: String

    /**
     A list of adopted protocols.

     For example,
     given the following declarations,
     the `inheritance` of protocol `P` is `["Q"]`:

     ```swift
     protocol Q {}
     protocol P: Q {}
     ```
    */
    public let inheritance: [String]

    /**
     The primary associated types for the declaration.

     For example,
     the following declaration of protocol `SomeProtocol`
     has a two primary associated types
     whose types are `Parameter` and `Object`


     ```swift
     protocol SomeProtocol<Parameter, Object> {}
     ```
     */
    public let primaryAssociatedTypes: [String]

    /// The location the function declaration starts on.
    public internal(set) var startLocation: DeclarationLocation = .empty()

    /// The location the declaration closes/ends on.
    public internal(set) var endLocation: DeclarationLocation = .empty()
}

// MARK: - ExpressibleBySyntax

extension Protocol: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: ProtocolDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.protocolKeyword.text.trimmed
        name = node.identifier.text.trimmed
        inheritance = node.inheritanceClause?.inheritedTypeCollection.map { $0.typeName.description.trimmed } ?? []
        // Get list of primary associated type tokens
        let primaryTypes = node.primaryAssociatedTypeClause?.primaryAssociatedTypeList.map(\.name) ?? []
        primaryAssociatedTypes = primaryTypes.map(\.text.trimmed)
    }
}

// MARK: - CustomStringConvertible

extension Protocol: CustomStringConvertible {
    public var description: String {
        var description = (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, name]
        ).joined(separator: " ")

        if !inheritance.isEmpty {
            description += ": \(inheritance.joined(separator: ", "))"
        }

        return description
    }
}
