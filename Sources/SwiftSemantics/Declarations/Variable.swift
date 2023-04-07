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
    public let parent: Parent?

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
    private(set) public var isOptional: Bool

    /// Will be assigned if the `type` represents a closure.
    private(set) public var closureType: ClosureDeclaration?

    /// Will be assigned if the `type` represents a tuple.
    private(set) public var tupleType: TupleDeclaration?

    /// The location the declaration starts on.
    public internal(set) var startLocation: DeclarationLocation = .empty()

    /// The location the declaration closes/ends on.
    public internal(set) var endLocation: DeclarationLocation = .empty()
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
        attributes = AttributesCollector.collect(parent)
        modifiers = parent.modifiers?.map { Modifier($0) } ?? []
        keyword = parent.letOrVarKeyword.text.trimmed
        name = node.pattern.description.trimmed
        typeAnnotation = node.typeAnnotation?.type.description.trimmed
        initializedValue = node.initializer?.value.description.trimmed
        accessors = Accessor.accessors(from: node.accessor?.as(AccessorBlockSyntax.self))
        // Assign parent
        self.parent = Parent(node.resolveRootParent())
        self.hasSetter = accessors.contains(where: { $0.kind == .set })
        // Standard optional check
        if let typeSyntax = node.children(viewMode: .fixedUp).first(where: { $0.syntaxNodeType == TypeAnnotationSyntax.self }) {
            isOptional = typeSyntax.children(viewMode: .fixedUp).contains(where: { $0.syntaxNodeType == OptionalTypeSyntax.self })
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
        // Check for immediate closure
        if let typeAnnotationSyntax = node.children(viewMode: .fixedUp).first(where: { $0.syntaxNodeType == TypeAnnotationSyntax.self }) {
            if typeAnnotationSyntax.children(viewMode: .fixedUp).contains(where: { $0.syntaxNodeType == FunctionTypeSyntax.self }) {
                closureType = ClosureDeclarationCollector.collect(node._syntaxNode)
                return
            }
        }
        // Closure/Tuple type
        var potentialTuple = TupleDeclarationCollector.collect(node._syntaxNode)
        while potentialTuple != nil {
            guard !potentialTuple!.arguments.isEmpty else { break }
            guard potentialTuple!.arguments.count == 1 else {
                tupleType = potentialTuple!
                break
            }
            guard let tupleParameter = potentialTuple!.arguments[0] as? TupleParameter else { break }
            potentialTuple = TupleDeclaration(tupleParameter)
        }
        if (tupleType?.arguments ?? []).isEmpty {
            closureType = ClosureDeclarationCollector.collect(node._syntaxNode)
        }
        if tupleType != nil, !isOptional {
            isOptional = Utils.SwiftSyntax.isVariableTupleDeclarationOptional(node)
        }
    }
}

extension SyntaxProtocol {

    func printDescription() {
        var results: [String] = []
        for (_, child) in children(viewMode: .fixedUp).enumerated() {
            results.append("\(0): \(child.syntaxNodeType)")
            traverseNode(child, indent: 0, results: &results)
        }
        let combined = results.joined(separator: "\n")
        print(combined)
    }

    func traverseNode(_ node: any SyntaxProtocol, indent: Int = 0, results: inout [String]) {
        for (_, child) in node.children(viewMode: .fixedUp).enumerated() {
            let prefix = String(Array(repeating: " ", count: indent + (indent + 1)))
            results.append("\(prefix)\(indent).\(indent + 1): \(child.syntaxNodeType)")
            traverseNode(child, indent: indent + 1, results: &results)
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

