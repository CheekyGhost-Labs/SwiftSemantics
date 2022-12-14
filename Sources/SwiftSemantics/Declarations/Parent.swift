//
//  File.swift
//  
//
//  Created by Cheeky Ghost Labson 13/8/2022.
//

import SwiftSyntax

/// Struct holding information about a declarations parent. The parent information can be used to locate other items in the collection for grouping.
public struct Parent: Equatable, Hashable, Codable {

    // MARK: - Properties

    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"protocol" or "extension"`).
    public let keyword: String

    /// The type name of the parent. i.e `"extension Sample { ..."` will assign `"Sample"`
    public let name: String

    // MARK: - Conveneince

    static var validParentTokens: [TokenKind] {
        [.structKeyword, .classKeyword, .protocolKeyword, .enumKeyword, .extensionKeyword]
    }

    // MARK: - Lifecycle

    init(attributes: [Attribute] = [], modifiers: [Modifier] = [], keyword: String, name: String) {
        self.attributes = attributes
        self.modifiers = modifiers
        self.keyword = keyword
        self.name = name
    }

    /// Creates an instance initialized with the given syntax node.
    public init?(_ node: Syntax?) {
        guard let node = node else {
            return nil
        }
        var workingTokenKind: TokenKind?
        if let tokenKind = node.firstToken?.tokenKind, Self.validParentTokens.contains(tokenKind) {
            workingTokenKind = tokenKind
        } else if let matchingChild = node.tokens.first(where: { childToken in return Self.validParentTokens.contains(childToken.tokenKind) }) {
            workingTokenKind = matchingChild.tokenKind
        }
        guard let targetKind = workingTokenKind else {
            return nil
        }
        // Struct
        switch targetKind {
        case .classKeyword:
            guard let classNode = ClassDeclSyntax(node) else { return nil }
            attributes = classNode.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
            modifiers = classNode.modifiers?.map { Modifier($0) } ?? []
            #if swift(>=5.5)
            keyword = classNode.classOrActorKeyword.text.trimmed
            #else
            keyword = classNode.classKeyword.text.trimmed
            #endif
            name = classNode.identifier.text.trimmed
        case .enumKeyword:
            guard let enumNode = EnumDeclSyntax(node) else { return nil }
            attributes = enumNode.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
            modifiers = enumNode.modifiers?.map { Modifier($0) } ?? []
            keyword = enumNode.enumKeyword.text.trimmed
            name = enumNode.identifier.text.trimmed
        case .extensionKeyword:
            guard let extensionNode = ExtensionDeclSyntax(node) else { return nil }
            attributes = extensionNode.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
            modifiers = extensionNode.modifiers?.map { Modifier($0) } ?? []
            keyword = extensionNode.extensionKeyword.text.trimmed
            name = extensionNode.extendedType.description.trimmed
        case .protocolKeyword:
            guard let protocolNode = ProtocolDeclSyntax(node) else { return nil }
            attributes = protocolNode.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
            modifiers = protocolNode.modifiers?.map { Modifier($0) } ?? []
            keyword = protocolNode.protocolKeyword.text.trimmed
            name = protocolNode.identifier.text.trimmed
        case .structKeyword:
            guard let structNode = StructDeclSyntax(node) else { return nil }
            attributes = structNode.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
            modifiers = structNode.modifiers?.map { Modifier($0) } ?? []
            keyword = structNode.structKeyword.text.trimmed
            name = structNode.identifier.text.trimmed
        default:
            return nil
        }
    }
}
