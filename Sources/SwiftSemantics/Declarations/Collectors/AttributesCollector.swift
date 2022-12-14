//
//  File.swift
//  
//
//  Created by Michael O'Brien on 3/12/2022.
//

import SwiftSyntax

class AttributesCollector: Collector {

    // MARK: - Convenience

    static func collect(_ node: SyntaxProtocol) -> [Attribute] {
        let collector = AttributesCollector()
        collector.walk(node)
        return collector.attributes ?? []
    }

    // MARK: - Properties

    var attributes: [Attribute]?

    // MARK: - Overrides

    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        return attributes != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: EnumCasePatternSyntax) -> SyntaxVisitorContinueKind {
        return attributes != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: SubscriptDeclSyntax) -> SyntaxVisitorContinueKind {
        return attributes != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        return attributes != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        return attributes != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: TupleTypeElementSyntax) -> SyntaxVisitorContinueKind {
        return attributes != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: AttributedTypeSyntax) -> SyntaxVisitorContinueKind {
        return attributes != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        return attributes != nil ? .skipChildren : .visitChildren
    }

    override func visit(_ node: AttributeListSyntax) -> SyntaxVisitorContinueKind {
        attributes = node.children.compactMap { $0.as(AttributeSyntax.self) }.map(Attribute.init)
        return .skipChildren
    }

    override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        attributes = [Attribute(node)]
        return .skipChildren
    }
}
