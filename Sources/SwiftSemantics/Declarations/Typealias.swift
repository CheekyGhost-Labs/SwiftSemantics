import Foundation
import SwiftSyntax

/// A type alias declaration.
public struct Typealias: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"typealias"`).
    public let keyword: String

    /// The type alias name.
    public let name: String

    /// The initialized type, if any.
    public let initializedType: String?

    /**
     The generic parameters for the declaration.

     For example,
     the following typealias declaration
     has a single generic parameter
     whose `name` is `"T"` and `type` is `"Comparable"`:

     ```swift
     typealias SortableArray<T: Comparable> = Array<T>
     ```
     */
    public let genericParameters: [GenericParameter]

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following typealias declaration
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Numeric"`:

     ```swift
     typealias ArrayOfNumbers<T> = Array<T> where T: Numeric
     ```
     */
    public let genericRequirements: [GenericRequirement]

    /// The parent entity that owns the typealias.
    public let parent: Parent?

    /// Will be assigned if the `type` represents a closure.
    private(set) public var closureType: ClosureDeclaration?
    
    /// Will be assigned if the `type` represents a tupe.
    private(set) public var tupleType: TupleDeclaration?

    /// The location the function declaration starts on.
    public internal(set) var startLocation: DeclarationLocation = .empty()

    /// The location the declaration closes/ends on.
    public internal(set) var endLocation: DeclarationLocation = .empty()
}

// MARK: - ExpressibleBySyntax

extension Typealias: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: TypealiasDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.typealiasKeyword.text.trimmed
        name = node.identifier.text.trimmed
        initializedType = node.initializer?.value.description.trimmed
        genericParameters = node.genericParameterClause?.genericParameterList.map { GenericParameter($0) } ?? []
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
        // Assign parent
        parent = Parent(node.resolveRootParent())
        // Check for immediate closure
        if let typeAnnotationSyntax = node.children.first(where: { $0.syntaxNodeType == TypeInitializerClauseSyntax.self }) {
            if typeAnnotationSyntax.children.contains(where: { $0.syntaxNodeType == FunctionTypeSyntax.self }) {
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
    }
}

// MARK: - CustomStringConvertible

extension Typealias: CustomStringConvertible {
    public var description: String {
        var description = (
        attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, name]
        ).joined(separator: " ")

        if !genericParameters.isEmpty {
            description += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        if let initializedType = initializedType {
            description += " = \(initializedType)"
        }

        if !genericRequirements.isEmpty {
            description += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return description
    }
}
