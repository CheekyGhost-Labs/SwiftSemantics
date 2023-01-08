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

    static var allTests = [
        ("testComplexFunctionDeclaration", testComplexFunctionDeclaration),
        ("testOperatorFunctionDeclarations", testOperatorFunctionDeclarations),
        ("testOperatorFunctionDeclarationsWithParent", testOperatorFunctionDeclarationsWithParent),
        ("testFunctionLineBounds", testFunctionLineBounds),
        ("testFunctionWithInoutAttributesWillStrip", testFunctionWithInoutAttributesWillStrip),
    ]
}

