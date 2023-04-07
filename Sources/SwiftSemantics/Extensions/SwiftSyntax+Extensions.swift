import SwiftSyntax

extension SyntaxProtocol {

    /// Will return the parent syntax context if it exists.
    var context: DeclSyntaxProtocol? {
        for case let node? in sequence(first: parent, next: { $0?.parent }) {
            guard let declaration = node.asProtocol(DeclSyntaxProtocol.self) else { continue }
            return declaration
        }

        return nil
    }
}

extension TokenKind {

    /// Will return `true` if the kind is the `identifier()` type.
    var isIdentifier: Bool {
        switch self {
        case .identifier(_):
            return true
        default:
            return false
        }
    }
}

extension DeclSyntaxProtocol {

    /// Array of valid token kinds included in a parent resolving check
    var validParentTokens: [TokenKind] {
        [.structKeyword, .classKeyword, .protocolKeyword, .enumKeyword, .extensionKeyword]
    }

    /// Will traverse upwards through the node's parents to find the root class, struct, or enum etc
    /// - Returns: The parent node
    func resolveRootParent() -> Syntax? {
        var parentNode = parent
        while parentNode != nil {
            parentNode = parentNode?.parent
            if let node = parentNode, node.tokens(viewMode: .fixedUp).contains(where: {
                validParentTokens.contains($0.tokenKind) && $0.isToken
            }) {
                if [0, 1].contains(node.indexInParent) {
                    if parentNode?.children(viewMode: .fixedUp).first(where: {
                        $0.tokens(viewMode: .fixedUp).contains(where: {
                            validParentTokens.contains($0.tokenKind)
                        })
                    }) != nil {
                        break
                    }
                }
            }
        }
        return parentNode
    }
}

extension SyntaxProtocol {

    /// Array of valid token kinds included in a parent resolving check
    var validParentTokens: [TokenKind] {
        [.structKeyword, .classKeyword, .protocolKeyword, .enumKeyword, .extensionKeyword]
    }

    /// Will traverse upwards through the node's parents to find the root class, struct, or enum etc
    /// - Returns: The parent node
    func resolveRootParent() -> Syntax? {
        var parentNode = parent
        while parentNode != nil {
            parentNode = parentNode?.parent
            if let node = parentNode, node.tokens(viewMode: .fixedUp).contains(where: {
                validParentTokens.contains($0.tokenKind) && $0.isToken
            }) {
                if [0, 1].contains(node.indexInParent) {
                    if parentNode?.children(viewMode: .fixedUp).first(where: {
                        $0.tokens(viewMode: .fixedUp).contains(where: {
                            validParentTokens.contains($0.tokenKind)
                        })
                    }) != nil {
                        break
                    }
                }
            }
        }
        return parentNode
    }

    func resolveParentType() -> String? {
        let parentNode = resolveRootParent()
        let validChild = parentNode?.children(viewMode: .fixedUp).first(where: {
            $0.tokens(viewMode: .fixedUp).contains(where: { validParentTokens.contains($0.tokenKind) })
        })
        if let nextToken = validChild?.nextToken, validParentTokens.contains(nextToken.tokenKind) || nextToken.tokenKind.isIdentifier {
            return nextToken.text
        }
        return nil
    }
}
