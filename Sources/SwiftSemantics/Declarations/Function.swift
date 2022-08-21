import Foundation
import SwiftSyntax

/// A function declaration.
public struct Function: Declaration, Hashable, Codable {
    /// The declaration attributes.
    public let attributes: [Attribute]

    /// The declaration modifiers.
    public let modifiers: [Modifier]

    /// The declaration keyword (`"func"`).
    public let keyword: String

    /// The function identifier.
    public let identifier: String

    /// The function signature.
    public let signature: Signature

    /**
     The generic parameters for the declaration.

     For example,
     the following declaration of function `f`
     has a single generic parameter
     whose `identifier` is `"T"` and `type` is `"Equatable"`:

     ```swift
     func f<T: Equatable>(value: T) {}
     ```
     */
    public let genericParameters: [GenericParameter]

    /**
     The generic parameter requirements for the declaration.

     For example,
     the following declaration of function `f`
     has a single requirement
     that its generic parameter identified as `"T"`
     conforms to the type identified as `"Hashable"`:

     ```swift
     func f<T>(value: T) where T: Hashable {}
     ```
     */
    public let genericRequirements: [GenericRequirement]

    /// Whether the function is an operator.
    public var isOperator: Bool {
        return Operator.Kind(modifiers) != nil || Operator.isValidIdentifier(identifier)
    }

    /// A function signature.
    public struct Signature: Hashable, Codable {
        /// The function inputs.
        public let input: [Parameter]

        /// The function output, if any.
        public let output: String?

        /// The `throws` or `rethrows` keyword, if any.
        public let throwsOrRethrowsKeyword: String?
    }

    /**
     A function parameter.

     This type can also be used to represent
     initializer parameters and associated values for enumeration cases.
     */
    public struct Parameter: Hashable, Codable {
        /// The declaration attributes.
        public let attributes: [Attribute]

        /**
         The first, external name of the parameter.

         For example,
         given the following function declaration,
         the first parameter has a `firstName` equal to `nil`,
         and the second parameter has a `firstName` equal to `"by"`:

         ```swift
         func increment(_ number: Int, by amount: Int = 1)
         ```
         */
        public let firstName: String?

        /**
         The second, internal name of the parameter.

         For example,
         given the following function declaration,
         the first parameter has a `secondName` equal to `"number"`,
         and the second parameter has a `secondName` equal to `"amount"`:

         ```swift
         func increment(_ number: Int, by amount: Int = 1)
         ```
        */
        public let secondName: String?

        /**
         The type identified by the parameter.

         For example,
         given the following function declaration,
         the first parameter has a `type` equal to `"Person"`,
         and the second parameter has a `type` equal to `"String"`:

         ```swift
         func greet(_ person: Person, with phrases: String...)
         ```
        */
        public let type: String?

        /**
         Whether the parameter accepts a variadic argument.

         For example,
         given the following function declaration,
         the second parameter is variadic:

         ```swift
         func greet(_ person: Person, with phrases: String...)
         ```
        */
        public let variadic: Bool

        /**
         The default argument of the parameter.

         For example,
         given the following function declaration,
         the second parameter has a default argument equal to `"1"`.

         ```swift
         func increment(_ number: Int, by amount: Int = 1)
         ```
         */
        public let defaultArgument: String?

        // MARK: - Convenience

        /// Will return `true` when the parameter is a closure type.
        public let isClosure: Bool

        /// WIll return the input type annotation for the closure. Returns an empty string if no input is found.
        public let closureInput: String

        /// WIll return the result type annotation for the closure. Returns an empty string if no result is found.
        public let closureResult: String

        /// WIll return`true` if the parameter is a closure and the input is a void block. i.e `(Void) -> String/ (()) -> String`.
        public let isClosureInputVoid: Bool

        /// WIll return`true` if the parameter is a closure and the input is a void block. i.e `() -> (Void)/() -> (())`.
        public let isClosureResultVoid: Bool

        /// Will return the `secondName` if available, falling back to the `firstName`. If neither is available an empty string will be returned.
        public let preferredName: String

        /// Will return the `typeAnnotation` without any attributes (such as `@escaping`). If the `typeAnnotation` is `nil` then `nil` will also be returned.
        public let typeWithoutAttributes: String?
    }

    /// The parent entity that owns the function.
    public let parent: Parent?

    public let parentInfo: Parent?
}

// MARK: - ExpressibleBySyntax

extension Function: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: FunctionDeclSyntax) {
        attributes = node.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
        modifiers = node.modifiers?.map { Modifier($0) } ?? []
        keyword = node.funcKeyword.text.trimmed
        identifier = node.identifier.text.trimmed
        signature = Signature(node.signature)
        genericParameters = node.genericParameterClause?.genericParameterList.map { GenericParameter($0) } ?? []
        genericRequirements = GenericRequirement.genericRequirements(from: node.genericWhereClause?.requirementList)
        // Assign parent
        parent = Parent(node.resolveRootParent())
        parentInfo = Parent(node.resolveRootParent())
    }
}

extension Function.Parameter: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: FunctionParameterSyntax) {
        attributes = node.attributes?.compactMap{ $0.as(AttributeSyntax.self) }.map { Attribute($0) } ?? []
        firstName = node.firstName?.text.trimmed
        secondName = node.secondName?.text.trimmed
        type = node.type?.description.trimmed
        variadic = node.ellipsis != nil
        defaultArgument = node.defaultArgument?.value.description.trimmed
        // Preferred Name
        if let secondName = secondName {
            self.preferredName = secondName
        } else if let firstName = firstName {
            self.preferredName = firstName
        } else {
            self.preferredName = ""
        }
        // Convenience
        let typeString = type ?? ""
        self.typeWithoutAttributes = typeString.replacingOccurrences(of: "\\@[\\w\\(\\)\\,]{1,}\\s{0,}", with: "", options: .regularExpression)
        // Closure Convenience
        let closureDetails = ClosureDetails(typeString: typeWithoutAttributes)
        self.isClosure = closureDetails?.isClosure ?? false
        self.closureInput = closureDetails?.closureInput ?? ""
        self.closureResult = closureDetails?.closureResult ?? ""
        self.isClosureInputVoid = closureDetails?.isClosureInputVoid ?? false
        self.isClosureResultVoid = closureDetails?.isClosureResultVoid ?? false
    }
}

extension Function.Signature: ExpressibleBySyntax {
    /// Creates an instance initialized with the given syntax node.
    public init(_ node: FunctionSignatureSyntax) {
        input = node.input.parameterList.map { Function.Parameter($0) }
        output = node.output?.returnType.description.trimmed
        throwsOrRethrowsKeyword = node.throwsOrRethrowsKeyword?.description.trimmed
    }
}

// MARK: - CustomStringConvertible

extension Function: CustomStringConvertible {
    public var description: String {
        var description = (
            attributes.map { $0.description } +
            modifiers.map { $0.description } +
            [keyword, identifier]
        ).joined(separator: " ")

        if !genericParameters.isEmpty {
            description += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        description += signature.description

        if !genericRequirements.isEmpty {
            description += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return description
    }
}

extension Function.Signature: CustomStringConvertible {
    public var description: String {
        var description = "(\(input.map { $0.description }.joined(separator: ", ")))"
        if let throwsOrRethrowsKeyword = throwsOrRethrowsKeyword {
            description += " \(throwsOrRethrowsKeyword)"
        }

        if let output = output {
            description += " -> \(output)"
        }

        return description
    }
}

extension Function.Parameter: CustomStringConvertible {
    public var description: String {
        var description: String = (attributes.map { $0.description } + [firstName, secondName].compactMap { $0?.description }).joined(separator: " ")
        if let type = type {
            description += ": \(type)"
        }

        if let defaultArgument = defaultArgument {
            description += " = \(defaultArgument)"
        }
        return description
    }
}
