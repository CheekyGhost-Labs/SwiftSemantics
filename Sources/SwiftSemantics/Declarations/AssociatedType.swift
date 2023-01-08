import SwiftSyntax

/// An associated type declaration.
public struct AssociatedType: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"associatedtype"`).
    public let keyword: String

    /// The associated type name.
    public let name: String

    /// The parent entity that owns the associated type.
    public let parent: Parent?

    /// The location the function declaration starts on.
    public internal(set) var startLocation: DeclarationLocation = .empty()

    /// The location the declaration closes/ends on.
    public internal(set) var endLocation: DeclarationLocation = .empty()
}

// MARK: - ExpressibleBySyntax

extension AssociatedType: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: AssociatedtypeDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.associatedtypeKeyword.text.trimmed
        name = node.identifier.text.trimmed
        // Assign parent
        parent = Parent(node.resolveRootParent())
    }
}

// MARK: - CustomStringConvertible

extension AssociatedType: CustomStringConvertible {
    public var description: String {
        return (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, name]
        ).joined(separator: " ")
    }
}
