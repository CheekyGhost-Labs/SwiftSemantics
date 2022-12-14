//
//  File.swift
//  
//
//  Created by Cheeky Ghost Labson 1/12/2022.
//

import Foundation
import SwiftSyntax

struct AnyParameter: Codable, Hashable, Equatable, CustomStringConvertible {

    // MARK: - Supplementary

    enum ParameterType {
        case function
        case variable
        case tuple
        case tupleArgument
        case closure
    }

    // MARK: - Properties

    /// The declaration attributes.
    var attributes: [Attribute]

    /**
     The first, external name of the parameter.

     For example,
     given the following function declaration,
     the first parameter has a `firstName` equal to `nil`,
     and the second parameter has a `firstName` equal to `"by"`:

     ```swift
     func increment(_ number: Int, by amount: Int = 1)
     // or in a closure
     (_ number: Int, by amount: Int) -> Void
     ```
     */
    var name: String?

    /**
     The second, internal name of the parameter.

     For example,
     given the following function declaration,
     the first parameter has a `secondName` equal to `"number"`,
     and the second parameter has a `secondName` equal to `"amount"`:

     ```swift
     func increment(_ number: Int, by amount: Int = 1)
     // or in a closure
     (_ number: Int, by amount: Int) -> (_ number: Int, by amount: Int)
     ```
    */
    var secondName: String?

    /**
     The type identified by the parameter.

     For example,
     given the following function declaration,
     the first parameter has a `type` equal to `"Person"`,
     and the second parameter has a `type` equal to `"String"`:

     ```swift
     func greet(_ person: Person, with phrases: String...)
     // or in a closure
     (_ person: Person, with phrases: String...)
     ```
    */
    var type: String?

    /**
     Whether the parameter accepts a variadic argument.

     For example,
     given the following function declaration,
     the second parameter is variadic:

     ```swift
     func greet(_ person: Person, with phrases: String...)
     ```
    */
    var variadic: Bool

    /// Will return a `Bool` flag indicating if the closure declaration is marked as optional. `?`
    var isOptional: Bool

    /**
     The default argument of the parameter.

     For example,
     given the following function declaration,
     the second parameter has a default argument equal to `"1"`.

     ```swift
     func increment(_ number: Int, by amount: Int = 1)
     ```
      **Note:** Closure input parameters don't support default values
     */
    var defaultArgument: String?

    /// Bool whether the parameter is marked with `inout`
    var isInOut: Bool

    /// Bool whether the parameter name is marked as no label `_`. This will be false for completely label-less types. i.e `(Int, String)` will both have `false`
    var isLabelOmitted: Bool

    /// Will return the `secondName` if available, falling back to the `firstName`. If neither is available an empty string will be returned.
    var preferredName: String?

    /// Will return the `typeAnnotation` without any attributes (such as `@escaping`). If the `typeAnnotation` is `nil` then `nil` will also be returned.
    var typeWithoutAttributes: String?

    // MARK: - CustomStringConvertible

    public var description: String {
        var description: String = (attributes.map { $0.description } + [name, secondName].compactMap { $0?.description }).joined(separator: " ")
        if let type = type {
            if name != nil || secondName != nil {
                description += ": \(type)"
            } else {
                description += "\(type)"
            }
        }

        if let defaultArgument = defaultArgument {
            description += " = \(defaultArgument)"
        }
        return description
    }
}
