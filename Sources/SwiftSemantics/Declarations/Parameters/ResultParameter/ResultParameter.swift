//
//  ResultParameter.swift
//  
//
//  Created by Michael O'Brien on 21/2/2023.
//

import SwiftSyntax

public struct ResultParameter: ParameterType {

    // MARK: Conformance: ParameterType

    private(set) public var attributes: [Attribute] = []

    private(set) public var name: String?

    private(set) public var secondName: String?

    private(set) public var type: String?

    private(set) public var variadic: Bool

    private(set) public var defaultArgument: String?

    private(set) public var isInOut: Bool

    private(set) public var isOptional: Bool

    private(set) public var preferredName: String?

    private(set) public var typeWithoutAttributes: String?

    // MARK: - Lifecycle

    public init(_ node: SimpleTypeIdentifierSyntax) {
        name = nil
        secondName = nil
        variadic = false
        isInOut = false
        preferredName = nil
        defaultArgument = nil
        isOptional = Utils.isTypeOptional(node.nextToken?.text)
        let suffix = isOptional ? "?" : ""
        let arguments = resolveGenericParameters(node)
        let joinedDescriptions = arguments.map(\.description).joined(separator: ", ")
        type = node.name.text + "<" + joinedDescriptions + ">" + suffix
        typeWithoutAttributes = Utils.stripAttributes(from: type)
//        let genericParameters = node.genericParameterClause?.genericParameterList.map { GenericParameter($0) } ?? []
        // The tuple might be an element within a larger tuple, or simply a declaration type within a parameter set
        // If a parent `TupleTypeElementSyntax` can be resolved then it has parameter properties.
        if let parent = resolveParentElementFromSyntax(node) {
            name = parent.name?.text
            secondName = parent.secondName?.text
            preferredName = Utils.getPreferredName(firstName: name, secondName: secondName, labelOmitted: Utils.isLabelOmitted(name))
            variadic = parent.ellipsis != nil
            defaultArgument = nil
            isInOut = parent.inOut != nil
        }
    }

    func resolveGenericParameters(_ node: SimpleTypeIdentifierSyntax) -> [any ParameterType] {
        guard
            let syntax = node.children(viewMode: .fixedUp).first(where: { $0._syntaxNode.syntaxNodeType == GenericArgumentClauseSyntax.self }),
            let genericArgumentClause = GenericArgumentClauseSyntax(syntax._syntaxNode)
        else {
            return []
        }
        let parameters = ResultArgumentCollector.collect(genericArgumentClause)
        return parameters
    }

    func resolveParentElementFromSyntax(_ node: SimpleTypeIdentifierSyntax) -> TupleTypeElementSyntax? {
        var parent: Syntax? = node.parent
        if parent?.syntaxNodeType == OptionalTypeSyntax.self {
            parent = parent?.parent
        }
        guard let resolved = parent else { return nil }
        return TupleTypeElementSyntax(resolved._syntaxNode)
    }
}
