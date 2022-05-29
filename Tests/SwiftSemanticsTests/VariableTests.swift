@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class VariableTests: XCTestCase {
    func testVariableDeclarationWithTypeAnnotation() throws {
        let source = #"""
        let greeting: String = "Hello"
        """#

        let declarations = try SyntaxParser.declarations(of: Variable.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.typeAnnotation, "String")
        XCTAssertEqual(declaration.initializedValue, "\"Hello\"")
        XCTAssertEqual(declaration.description, source)
        XCTAssertNil(declaration.parent)
    }

    func testVariableDeclarationWithParent() throws {
        let source = #"""
        class SampleClass {
            let greeting: String = "Hello"

            struct SampleStruct {
                let structVar: String = "Hello"
            }
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Variable.self, source: source)
        XCTAssertEqual(declarations.count, 2)

        XCTAssert(declarations[0].attributes.isEmpty)
        XCTAssertEqual(declarations[0].typeAnnotation, "String")
        XCTAssertEqual(declarations[0].initializedValue, "\"Hello\"")
        XCTAssertEqual(declarations[0].description, "let greeting: String = \"Hello\"")
        XCTAssertEqual(declarations[0].parent, "SampleClass")

        XCTAssert(declarations[1].attributes.isEmpty)
        XCTAssertEqual(declarations[1].typeAnnotation, "String")
        XCTAssertEqual(declarations[1].initializedValue, "\"Hello\"")
        XCTAssertEqual(declarations[1].description, "let structVar: String = \"Hello\"")
        XCTAssertEqual(declarations[1].parent, "SampleStruct")
    }

    func testVariableDeclarationWithoutTypeAnnotation() throws {
        let source = #"""
        let greeting = "Hello"
        """#

        let declarations = try SyntaxParser.declarations(of: Variable.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertNil(declaration.typeAnnotation)
        XCTAssertEqual(declaration.initializedValue, "\"Hello\"")
        XCTAssertEqual(declaration.description, source)
        XCTAssertNil(declaration.parent)
    }

    func testTupleVariableDeclaration() throws {
        let source = #"""
        let (greeting, addressee): (String, Thing) = ("Hello", .world)
        """#

              let declarations = try SyntaxParser.declarations(of: Variable.self, source: source)
          XCTAssertEqual(declarations.count, 1)
          let declaration = declarations.first!

          XCTAssert(declaration.attributes.isEmpty)
          XCTAssertEqual(declaration.typeAnnotation, "(String, Thing)")
          XCTAssertEqual(declaration.initializedValue, "(\"Hello\", .world)")
          XCTAssertEqual(declaration.description, source)
        XCTAssertNil(declaration.parent)
    }

    func testMultipleVariableDeclaration() throws {
        let source = #"""
        let greeting: String = "Hello", addressee: Thing = .world
        """#

        let declarations = try SyntaxParser.declarations(of: Variable.self, source: source)

        XCTAssertEqual(declarations.count, 2)

        let first = declarations.first!
        XCTAssert(first.attributes.isEmpty)
        XCTAssertEqual(first.typeAnnotation, "String")
        XCTAssertEqual(first.initializedValue, "\"Hello\"")
        XCTAssertNil(first.parent)

        let last = declarations.last!
        XCTAssert(last.attributes.isEmpty)
        XCTAssertEqual(last.typeAnnotation, "Thing")
        XCTAssertEqual(last.initializedValue, ".world")
        XCTAssertNil(last.parent)
    }

    static var allTests = [
        ("testVariableDeclarationWithTypeAnnotation", testVariableDeclarationWithTypeAnnotation),
        ("testVariableDeclarationWithoutTypeAnnotation", testVariableDeclarationWithoutTypeAnnotation),
        ("testTupleVariableDeclaration", testTupleVariableDeclaration),
        ("testMultipleVariableDeclaration", testMultipleVariableDeclaration),
    ]
}

