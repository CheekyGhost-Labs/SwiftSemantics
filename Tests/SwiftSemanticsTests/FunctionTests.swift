@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class FunctionTests: XCTestCase {
    func testComplexFunctionDeclaration() throws {
        let source = #"""
        public func dump<T, TargetStream>(_ value: T, to target: inout TargetStream, name: String? = nil, indent: Int = 0, maxDepth: Int = .max, maxItems: Int = .max) -> T where TargetStream: TextOutputStream
        """#
        
        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.identifier, "dump")
        XCTAssertEqual(declaration.description, source)
        XCTAssertNil(declaration.parent)
    }

    func testOperatorFunctionDeclarations() throws {
        let source = #"""
        prefix func ¬(value: Bool) -> Bool { !value }
        func ±(lhs: Int, rhs: Int) -> (Int, Int) { (lhs + rhs, lhs - rhs) }
        postfix func °(value: Double) -> String { "\(value)°)" }
        extension Int {
            static func ∓(lhs: Int, rhs: Int) -> (Int, Int) { (lhs - rhs, lhs + rhs) }
        }
        func sayHello() { print("Hello") }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 5)

        let prefix = declarations[0]
        XCTAssertEqual(prefix.modifiers.map { $0.description}, ["prefix"])
        XCTAssertEqual(prefix.identifier, "¬")
        XCTAssertTrue(prefix.isOperator)
        XCTAssertNil(prefix.parent)

        let infix = declarations[1]
        XCTAssert(infix.modifiers.isEmpty)
        XCTAssertEqual(infix.identifier, "±")
        XCTAssertTrue(infix.isOperator)
        XCTAssertNil(prefix.parent)

        let postfix = declarations[2]
        XCTAssertEqual(postfix.modifiers.map { $0.description}, ["postfix"])
        XCTAssertEqual(postfix.identifier, "°")
        XCTAssertTrue(postfix.isOperator)
        XCTAssertNil(prefix.parent)

        let staticInfix = declarations[3]
        XCTAssertEqual(staticInfix.modifiers.map { $0.description}, ["static"])
        XCTAssertEqual(staticInfix.identifier, "∓")
        XCTAssertTrue(staticInfix.isOperator)
        XCTAssertEqual(staticInfix.parent, Parent(keyword: "extension", name: "Int"))

        let nonoperator = declarations[4]
        XCTAssert(nonoperator.modifiers.isEmpty)
        XCTAssertEqual(nonoperator.identifier, "sayHello")
        XCTAssertFalse(nonoperator.isOperator)
        XCTAssertNil(prefix.parent)
    }

    func testOperatorFunctionDeclarationsWithParent() throws {
        let source = #"""
        struct Sample {
            prefix func ¬(value: Bool) -> Bool { !value }
            func ±(lhs: Int, rhs: Int) -> (Int, Int) { (lhs + rhs, lhs - rhs) }
            postfix func °(value: Double) -> String { "\(value)°)" }
            func sayHello() { print("Hello") }
        }
        extension Int {
            static func ∓(lhs: Int, rhs: Int) -> (Int, Int) { (lhs - rhs, lhs + rhs) }
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 5)

        let prefix = declarations[0]
        XCTAssertEqual(prefix.modifiers.map { $0.description}, ["prefix"])
        XCTAssertEqual(prefix.identifier, "¬")
        XCTAssertTrue(prefix.isOperator)
        XCTAssertEqual(prefix.parent, Parent(keyword: "struct", name: "Sample"))

        let infix = declarations[1]
        XCTAssert(infix.modifiers.isEmpty)
        XCTAssertEqual(infix.identifier, "±")
        XCTAssertTrue(infix.isOperator)
        XCTAssertEqual(infix.parent, Parent(keyword: "struct", name: "Sample"))

        let postfix = declarations[2]
        XCTAssertEqual(postfix.modifiers.map { $0.description}, ["postfix"])
        XCTAssertEqual(postfix.identifier, "°")
        XCTAssertTrue(postfix.isOperator)
        XCTAssertEqual(postfix.parent, Parent(keyword: "struct", name: "Sample"))

        let nonoperator = declarations[3]
        XCTAssert(nonoperator.modifiers.isEmpty)
        XCTAssertEqual(nonoperator.identifier, "sayHello")
        XCTAssertFalse(nonoperator.isOperator)
        XCTAssertEqual(nonoperator.parent, Parent(keyword: "struct", name: "Sample"))

        let staticInfix = declarations[4]
        XCTAssertEqual(staticInfix.modifiers.map { $0.description}, ["static"])
        XCTAssertEqual(staticInfix.identifier, "∓")
        XCTAssertTrue(staticInfix.isOperator)
        XCTAssertEqual(staticInfix.parent, Parent(keyword: "extension", name: "Int"))
    }

    func testFunctionWithParentInExtensionOnType() throws {
        let source = #"""
        struct Sample {
            func sayHello() { print("Hello Extension") }
        }
        extension Sample {
            func sayHello() { print("Hello Extension") }
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 2)

        let original = declarations[0]
        XCTAssertTrue(original.modifiers.isEmpty)
        XCTAssertEqual(original.identifier, "sayHello")
        XCTAssertEqual(original.parent, Parent(keyword: "struct", name: "Sample"))

        let extended = declarations[1]
        XCTAssertTrue(extended.modifiers.isEmpty)
        XCTAssertEqual(extended.identifier, "sayHello")
        XCTAssertEqual(extended.parent, Parent(keyword: "extension", name: "Sample"))
    }

    func testSourceLocations() throws {
        let source = #"""
        struct Sample {
            func sayHello(_ handler: @escaping (Int) -> Void) {
                print("Hello World")
            }
            func sayHelloAgain(_ handler: @autoclosure () -> Any) { print("Hello Again World") }
        }
        enum Thing {
            func sample() {
                // no-op
            }
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 3)
        XCTAssertEqual(declarations[0].startLocation.line, 1)
        XCTAssertEqual(declarations[0].startLocation.utf8Offset, 20)
        XCTAssertEqual(declarations[0].endLocation.line, 3)
        XCTAssertEqual(declarations[0].endLocation.utf8Offset, 106)
        XCTAssertEqual(declarations[0].startLocation.column, 4)
        XCTAssertEqual(declarations[0].endLocation.column, 5)
        XCTAssertEqual(
            declarations[0].extractFromSource(source),
            "func sayHello(_ handler: @escaping (Int) -> Void) {\n        print(\"Hello World\")\n    }"
        )
        XCTAssertEqual(declarations[1].startLocation.line, 4)
        XCTAssertEqual(declarations[1].startLocation.utf8Offset, 111)
        XCTAssertEqual(declarations[1].endLocation.line, 4)
        XCTAssertEqual(declarations[1].endLocation.utf8Offset, 195)
        XCTAssertEqual(declarations[1].startLocation.column, 4)
        XCTAssertEqual(declarations[1].endLocation.column, 88)
        XCTAssertEqual(
            declarations[1].extractFromSource(source),
            "func sayHelloAgain(_ handler: @autoclosure () -> Any) { print(\"Hello Again World\") }"
        )
        XCTAssertEqual(declarations[2].startLocation.line, 7)
        XCTAssertEqual(declarations[2].startLocation.utf8Offset, 215)
        XCTAssertEqual(declarations[2].endLocation.line, 9)
        XCTAssertEqual(declarations[2].endLocation.utf8Offset, 253)
        XCTAssertEqual(declarations[2].startLocation.column, 4)
        XCTAssertEqual(declarations[2].endLocation.column, 5)
        XCTAssertEqual(
            declarations[2].extractFromSource(source),
            "func sample() {\n        // no-op\n    }"
        )
    }

    func testFunctionWithInoutAttributesWillStrip() throws {
        let source = #"""
        struct Sample {
            func sayHello(_ handler: @escaping (Int) -> Void) { print("Hello World") }
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 1)

        let original = declarations[0]
        XCTAssertEqual(original.signature.input[0].typeWithoutAttributes, "(Int) -> Void")
    }

    func testFunctionWithClosureInput() throws {
        let source = #"""
        struct Sample {
            func renderPerson(_ name: String, age: Int, _ handler: (() -> Void)) {}
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 1)

        let original = declarations[0]
        XCTAssertEqual(original.signature.input.count, 3)
        // String
        XCTAssertEqual(original.signature.input[0].name, "_")
        XCTAssertEqual(original.signature.input[0].secondName, "name")
        XCTAssertTrue(original.signature.input[0].isLabelOmitted)
        XCTAssertEqual(original.signature.input[0].typeWithoutAttributes, "String")
        // Int
        XCTAssertEqual(original.signature.input[1].name, "age")
        XCTAssertEqual(original.signature.input[1].secondName, nil)
        XCTAssertFalse(original.signature.input[1].isLabelOmitted)
        XCTAssertEqual(original.signature.input[1].typeWithoutAttributes, "Int")
        // Closure
        XCTAssertEqual(original.signature.input[2].name, "_")
        XCTAssertEqual(original.signature.input[2].secondName, "handler")
        XCTAssertTrue(original.signature.input[2].isLabelOmitted)
        XCTAssertFalse(original.signature.input[2].isOptional)
        XCTAssertFalse(original.signature.input[2].isEscaping)
        XCTAssertEqual(original.signature.input[2].typeWithoutAttributes, "(() -> Void)")
        let closureInput = try XCTUnwrap(original.signature.input[2] as? ClosureParameter)
        XCTAssertEqual(closureInput.inputs.count, 0)
        XCTAssertTrue(closureInput.isVoidInput)
        XCTAssertTrue(closureInput.isVoidOutput)
    }

    func testFunctionWithEscapingClosureInput() throws {
        let source = #"""
        struct Sample {
            func renderPerson(_ name: String, age: Int, _ handler: @escaping (() -> Void)) {}
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 1)

        let original = declarations[0]
        XCTAssertEqual(original.signature.input.count, 3)
        // String
        XCTAssertEqual(original.signature.input[0].name, "_")
        XCTAssertEqual(original.signature.input[0].secondName, "name")
        XCTAssertTrue(original.signature.input[0].isLabelOmitted)
        XCTAssertEqual(original.signature.input[0].typeWithoutAttributes, "String")
        // Int
        XCTAssertEqual(original.signature.input[1].name, "age")
        XCTAssertEqual(original.signature.input[1].secondName, nil)
        XCTAssertFalse(original.signature.input[1].isLabelOmitted)
        XCTAssertEqual(original.signature.input[1].typeWithoutAttributes, "Int")
        // Closure
        XCTAssertEqual(original.signature.input[2].name, "_")
        XCTAssertEqual(original.signature.input[2].secondName, "handler")
        XCTAssertTrue(original.signature.input[2].isLabelOmitted)
        XCTAssertFalse(original.signature.input[2].isOptional)
        XCTAssertTrue(original.signature.input[2].isEscaping)
        XCTAssertEqual(original.signature.input[2].typeWithoutAttributes, "(() -> Void)")
        let closureInput = try XCTUnwrap(original.signature.input[2] as? ClosureParameter)
        XCTAssertEqual(closureInput.inputs.count, 0)
        XCTAssertTrue(closureInput.isVoidInput)
        XCTAssertTrue(closureInput.isVoidOutput)
    }

    func testFunctionWithOptionalClosureInput() throws {
        let source = #"""
        struct Sample {
            func renderPerson(_ name: String, age: Int, _ handler: @escaping (() -> Void)?) {}
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 1)

        let original = declarations[0]
        XCTAssertEqual(original.signature.input.count, 3)
        // String
        XCTAssertEqual(original.signature.input[0].name, "_")
        XCTAssertEqual(original.signature.input[0].secondName, "name")
        XCTAssertTrue(original.signature.input[0].isLabelOmitted)
        XCTAssertEqual(original.signature.input[0].typeWithoutAttributes, "String")
        // Int
        XCTAssertEqual(original.signature.input[1].name, "age")
        XCTAssertEqual(original.signature.input[1].secondName, nil)
        XCTAssertFalse(original.signature.input[1].isLabelOmitted)
        XCTAssertEqual(original.signature.input[1].typeWithoutAttributes, "Int")
        // Closure
        XCTAssertEqual(original.signature.input[2].name, "_")
        XCTAssertEqual(original.signature.input[2].secondName, "handler")
        XCTAssertTrue(original.signature.input[2].isLabelOmitted)
        XCTAssertTrue(original.signature.input[2].isOptional)
        XCTAssertTrue(original.signature.input[2].isEscaping)
        XCTAssertEqual(original.signature.input[2].typeWithoutAttributes, "(() -> Void)?")
        let closureInput = try XCTUnwrap(original.signature.input[2] as? ClosureParameter)
        XCTAssertEqual(closureInput.inputs.count, 0)
        XCTAssertTrue(closureInput.isVoidInput)
        XCTAssertTrue(closureInput.isVoidOutput)
    }

    func testFunctionWithTupleInput() throws {
        let source = #"""
        struct Sample {
            func renderPerson(_ name: String, age: Int, _ handler: (name: String, age: Int)) {}
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 1)

        let original = declarations[0]
        XCTAssertEqual(original.signature.input.count, 3)
        // String
        XCTAssertEqual(original.signature.input[0].name, "_")
        XCTAssertEqual(original.signature.input[0].secondName, "name")
        XCTAssertTrue(original.signature.input[0].isLabelOmitted)
        XCTAssertEqual(original.signature.input[0].typeWithoutAttributes, "String")
        // Int
        XCTAssertEqual(original.signature.input[1].name, "age")
        XCTAssertEqual(original.signature.input[1].secondName, nil)
        XCTAssertFalse(original.signature.input[1].isLabelOmitted)
        XCTAssertEqual(original.signature.input[1].typeWithoutAttributes, "Int")
        // Closure
        XCTAssertEqual(original.signature.input[2].name, "_")
        XCTAssertEqual(original.signature.input[2].secondName, "handler")
        XCTAssertTrue(original.signature.input[2].isLabelOmitted)
        XCTAssertFalse(original.signature.input[2].isOptional)
        XCTAssertEqual(original.signature.input[2].typeWithoutAttributes, "(name: String, age: Int)")
        let tupleInput = try XCTUnwrap(original.signature.input[2] as? TupleParameter)
        XCTAssertEqual(tupleInput.arguments.count, 2)
        XCTAssertEqual(tupleInput.arguments[0].name, "name")
        XCTAssertEqual(tupleInput.arguments[0].typeWithoutAttributes, "String")
        XCTAssertEqual(tupleInput.arguments[1].name, "age")
        XCTAssertEqual(tupleInput.arguments[1].typeWithoutAttributes, "Int")
    }

    func testFunctionWithOptionalTupleInput() throws {
        let source = #"""
        struct Sample {
            func renderPerson(_ name: String, age: Int, _ handler: (name: String, age: Int)?) {}
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 1)

        let original = declarations[0]
        XCTAssertEqual(original.signature.input.count, 3)
        // String
        XCTAssertEqual(original.signature.input[0].name, "_")
        XCTAssertEqual(original.signature.input[0].secondName, "name")
        XCTAssertTrue(original.signature.input[0].isLabelOmitted)
        XCTAssertEqual(original.signature.input[0].typeWithoutAttributes, "String")
        // Int
        XCTAssertEqual(original.signature.input[1].name, "age")
        XCTAssertEqual(original.signature.input[1].secondName, nil)
        XCTAssertFalse(original.signature.input[1].isLabelOmitted)
        XCTAssertEqual(original.signature.input[1].typeWithoutAttributes, "Int")
        // Closure
        XCTAssertEqual(original.signature.input[2].name, "_")
        XCTAssertEqual(original.signature.input[2].secondName, "handler")
        XCTAssertTrue(original.signature.input[2].isLabelOmitted)
        XCTAssertTrue(original.signature.input[2].isOptional)
        XCTAssertEqual(original.signature.input[2].typeWithoutAttributes, "(name: String, age: Int)?")
        let tupleInput = try XCTUnwrap(original.signature.input[2] as? TupleParameter)
        XCTAssertEqual(tupleInput.arguments.count, 2)
        XCTAssertEqual(tupleInput.arguments[0].name, "name")
        XCTAssertEqual(tupleInput.arguments[0].typeWithoutAttributes, "String")
        XCTAssertEqual(tupleInput.arguments[1].name, "age")
        XCTAssertEqual(tupleInput.arguments[1].typeWithoutAttributes, "Int")
    }

    func testFunctionWithInoutInput() throws {
        let source = #"""
        struct Sample {
            func performOperation(with names: inout [String]?) {}
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 1)
        XCTAssertEqual(declarations[0].signature.input.count, 1)
        XCTAssertEqual(declarations[0].signature.input[0].name, "with")
        XCTAssertEqual(declarations[0].signature.input[0].secondName, "names")
        XCTAssertEqual(declarations[0].signature.input[0].type, "inout [String]?")
        XCTAssertEqual(declarations[0].signature.input[0].typeWithoutAttributes, "[String]?")
        XCTAssertTrue(declarations[0].signature.input[0].isOptional)
        XCTAssertTrue(declarations[0].signature.input[0].isInOut)
    }

    func testFunctionWithClosureInputWithInoutArgument() throws {
        let source = #"""
        struct Sample {
            func performOperation(_ handler: @escaping (inout [String], Int) -> Void) {}
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 1)
        XCTAssertEqual(declarations[0].description, "func performOperation(_ handler: @escaping (inout [String], Int) -> Void)")
        XCTAssertEqual(declarations[0].signature.input.count, 1)
        XCTAssertEqual(declarations[0].signature.input[0].name, "_")
        XCTAssertEqual(declarations[0].signature.input[0].secondName, "handler")
        XCTAssertEqual(declarations[0].signature.input[0].type, "@escaping (inout [String], Int) -> Void")
        XCTAssertEqual(declarations[0].signature.input[0].typeWithoutAttributes, "(inout [String], Int) -> Void")
        XCTAssertFalse(declarations[0].signature.input[0].isOptional)
        XCTAssertFalse(declarations[0].signature.input[0].isInOut)
        let closure = try XCTUnwrap(declarations[0].signature.input[0] as? ClosureParameter)
        XCTAssertFalse(closure.isVoidInput)
        XCTAssertTrue(closure.isVoidOutput)
        XCTAssertTrue(closure.inputs[0].isInOut)
        XCTAssertEqual(closure.inputs[0].type, "[String]")
        XCTAssertFalse(closure.inputs[1].isInOut)
        XCTAssertEqual(closure.inputs[1].type, "Int")
    }

    static var allTests = [
        ("testComplexFunctionDeclaration", testComplexFunctionDeclaration),
        ("testOperatorFunctionDeclarations", testOperatorFunctionDeclarations),
        ("testOperatorFunctionDeclarationsWithParent", testOperatorFunctionDeclarationsWithParent),
        ("testFunctionWithInoutAttributesWillStrip", testFunctionWithInoutAttributesWillStrip),
    ]
}
