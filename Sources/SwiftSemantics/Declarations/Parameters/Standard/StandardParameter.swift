//
//  StandardParameter.swift
//  
//
//  Created by Cheeky Ghost Labson 1/12/2022.
//

import Foundation
import SwiftSyntax

public struct StandardParameter: ParameterType {

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

    public init(_ node: FunctionParameterSyntax) {
        attributes = node.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
        name = node.firstName?.text.trimmed
        secondName = node.secondName?.text.trimmed
        type = node.type?.description.trimmed
        variadic = node.ellipsis != nil
        defaultArgument = node.defaultArgument?.value.description.trimmed
        isInOut = node.type?.tokens.contains(where: { $0.tokenKind == .inoutKeyword }) ?? false
        isOptional = Utils.isTypeOptional(type)
        preferredName = Utils.getPreferredName(firstName: name, secondName: secondName, labelOmitted: Utils.isLabelOmitted(name))
        typeWithoutAttributes = Utils.stripAttributes(from: type)
    }

    public init(_ node: SimpleTypeIdentifierSyntax) {
        name = nil
        secondName = nil
        variadic = false
        isInOut = false
        preferredName = nil
        defaultArgument = nil
        isOptional = Utils.isTypeOptional(node.nextToken?.text)
        let suffix = isOptional ? "?" : ""
        type = node.name.text + suffix
        typeWithoutAttributes = Utils.stripAttributes(from: type)
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

    public init(_ node: TupleTypeElementListSyntax.Element) {
        name = node.name?.text
        secondName = node.secondName?.text
        type = node.type.description.trimmed
        defaultArgument = nil
        typeWithoutAttributes = Utils.stripAttributes(from: type)
        variadic = node.ellipsis != nil
        isInOut = node.inOut != nil
        preferredName = Utils.getPreferredName(firstName: name, secondName: secondName, labelOmitted: Utils.isLabelOmitted(name))
        var isOptional = Utils.isTypeOptional(type)
        if !isOptional {
            // Check single wrapped optional (<>)?
            var potentialOptional: Bool = false
            var nextToken = node.nextToken
            while nextToken != nil {
                if nextToken?.text == ")" {
                    potentialOptional = true
                }
                if potentialOptional, nextToken?.text == ")" {
                    break
                }
                if potentialOptional, nextToken?.text == "?" {
                    isOptional = true
                    break
                }
                nextToken = nextToken?.nextToken
            }
        }
        self.isOptional = isOptional
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
