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

    func testFunctionWithAttributesWillStrip() throws {
        let source = #"""
        struct Sample {
            func sayHello(_ handler: @escaping (Int) -> Void) { print("Hello World") }
            func sayHelloAgain(_ handler: @autoclosure () -> Any) { print("Hello Again World") }
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 2)

        let original = declarations[0]
        XCTAssertEqual(original.signature.input[0].typeWithoutAttributes, "(Int) -> Void")

        let repeated = declarations[1]
        XCTAssertEqual(repeated.signature.input[0].typeWithoutAttributes, "() -> Any")
    }

    func testFunctionWithInoutAttributesWillStrip() throws {
        let source = #"""
        struct Sample {
            func sayHello(_ handler: inout Int) { print("Hello World") }
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Function.self, source: source)

        XCTAssertEqual(declarations.count, 1)

        let original = declarations[0]
        XCTAssertEqual(original.signature.input[0].typeWithoutAttributes, "Int")
    }

    static var allTests = [
        ("testComplexFunctionDeclaration", testComplexFunctionDeclaration),
        ("testOperatorFunctionDeclarations", testOperatorFunctionDeclarations),
        ("testOperatorFunctionDeclarationsWithParent", testOperatorFunctionDeclarationsWithParent),
    ]
}

