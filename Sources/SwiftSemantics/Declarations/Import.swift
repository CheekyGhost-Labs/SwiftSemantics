import SwiftSyntax

/// An import declaration.
public struct Import: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The import keyword (`"import"`).
    public let keyword: String

    public let kind: String?

    public let pathComponents: [String]

    /// The location the function declaration starts on.
    public internal(set) var startLocation: DeclarationLocation = .empty()

    /// The location the declaration closes/ends on.
    public internal(set) var endLocation: DeclarationLocation = .empty()
}

// MARK: - ExpressibleBySyntax

extension Import: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: ImportDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.importTok.text.trimmed
        kind = node.importKind?.text.trimmed
        pathComponents = node.path.tokens(viewMode: .fixedUp).filter { $0.tokenKind != .period }.map { $0.text.trimmed }
    }
}

// MARK: - CustomStringConvertible

extension Import: CustomStringConvertible {
    public var description: String {
        return (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, kind] +
            [pathComponents.joined(separator: ".")]
        ).compactMap { $0 }.joined(separator: " ")
    }
}
