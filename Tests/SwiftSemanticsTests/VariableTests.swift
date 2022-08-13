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
        XCTAssertEqual(declarations[0].parent, Parent(keyword: "class", name: "SampleClass"))

        XCTAssert(declarations[1].attributes.isEmpty)
        XCTAssertEqual(declarations[1].typeAnnotation, "String")
        XCTAssertEqual(declarations[1].initializedValue, "\"Hello\"")
        XCTAssertEqual(declarations[1].description, "let structVar: String = \"Hello\"")
        XCTAssertEqual(declarations[1].parent, Parent(keyword: "struct", name: "SampleStruct"))
    }

    func testClosureVariableDeclaration() throws {
        let source = #"""
        let noInputClosure: (() -> String?)
        let voidInputClosure: ((Void) -> String?)
        let voidInputClosureAlt: (()) -> ()
        let primitiveInputClosure: (String) -> ()
        let tupleInputClosure: ((String, Int)) -> ()
        let emptyResultClosure: () -> ()
        let voidResultClosure: () -> Void
        let primitiveResultClosure: () -> String
        let tupleResultClosure: () -> (String, Int)
        let notClosure: String = ""
        """#

        let declarations = try SyntaxParser.declarations(of: Variable.self, source: source)
        XCTAssertEqual(declarations.count, 10)

        // No Input Closure
        XCTAssert(declarations[0].attributes.isEmpty)
        XCTAssertEqual(declarations[0].typeAnnotation, "(() -> String?)")
        XCTAssertNil(declarations[0].initializedValue)
        XCTAssertEqual(declarations[0].description, "let noInputClosure: (() -> String?)")
        XCTAssertTrue(declarations[0].isClosure)
        XCTAssertFalse(declarations[0].isClosureInputVoid)

        // Void Input Closure
        let voidInput = declarations[1]
        XCTAssert(voidInput.attributes.isEmpty)
        XCTAssertEqual(voidInput.typeAnnotation, "((Void) -> String?)")
        XCTAssertNil(voidInput.initializedValue)
        XCTAssertEqual(voidInput.description, "let voidInputClosure: ((Void) -> String?)")
        XCTAssertTrue(voidInput.isClosure)
        XCTAssertTrue(voidInput.isClosureInputVoid)
        XCTAssertEqual(voidInput.closureInput, "(Void)")

        // Alternate Void Input Closure
        let altVoidInput = declarations[2]
        XCTAssert(altVoidInput.attributes.isEmpty)
        XCTAssertEqual(altVoidInput.typeAnnotation, "(()) -> ()")
        XCTAssertNil(altVoidInput.initializedValue)
        XCTAssertEqual(altVoidInput.description, "let voidInputClosureAlt: (()) -> ()")
        XCTAssertTrue(altVoidInput.isClosure)
        XCTAssertTrue(altVoidInput.isClosureInputVoid)
        XCTAssertEqual(altVoidInput.closureInput, "()")

        // Primitive Input Closure
        let primitiveInput = declarations[3]
        XCTAssert(primitiveInput.attributes.isEmpty)
        XCTAssertEqual(primitiveInput.typeAnnotation, "(String) -> ()")
        XCTAssertNil(primitiveInput.initializedValue)
        XCTAssertEqual(primitiveInput.description, "let primitiveInputClosure: (String) -> ()")
        XCTAssertTrue(primitiveInput.isClosure)
        XCTAssertFalse(primitiveInput.isClosureInputVoid)
        XCTAssertEqual(primitiveInput.closureInput, "(String)")

        // Tuple Input Closure
        let tupleInputClosure = declarations[4]
        XCTAssert(tupleInputClosure.attributes.isEmpty)
        XCTAssertEqual(tupleInputClosure.typeAnnotation, "((String, Int)) -> ()")
        XCTAssertNil(tupleInputClosure.initializedValue)
        XCTAssertEqual(tupleInputClosure.description, "let tupleInputClosure: ((String, Int)) -> ()")
        XCTAssertTrue(tupleInputClosure.isClosure)
        XCTAssertFalse(tupleInputClosure.isClosureInputVoid)
        XCTAssertEqual(tupleInputClosure.closureInput, "(String, Int)")

        // Empty Input Closure
        let emptyInputClosure = declarations[5]
        XCTAssert(emptyInputClosure.attributes.isEmpty)
        XCTAssertEqual(emptyInputClosure.typeAnnotation, "() -> ()")
        XCTAssertNil(emptyInputClosure.initializedValue)
        XCTAssertEqual(emptyInputClosure.description, "let emptyResultClosure: () -> ()")
        XCTAssertTrue(emptyInputClosure.isClosure)
        XCTAssertFalse(emptyInputClosure.isClosureInputVoid)
        XCTAssertEqual(emptyInputClosure.closureInput, "()")

        // Void Result Closure
        let voidResultClosure = declarations[6]
        XCTAssert(voidResultClosure.attributes.isEmpty)
        XCTAssertEqual(voidResultClosure.typeAnnotation, "() -> Void")
        XCTAssertNil(voidResultClosure.initializedValue)
        XCTAssertEqual(voidResultClosure.description, "let voidResultClosure: () -> Void")
        XCTAssertTrue(voidResultClosure.isClosure)
        XCTAssertTrue(voidResultClosure.isClosureResultVoid)
        XCTAssertEqual(voidResultClosure.closureResult, "Void")

        // Primitive Result Closure
        let primitiveResultClosure = declarations[7]
        XCTAssert(primitiveResultClosure.attributes.isEmpty)
        XCTAssertEqual(primitiveResultClosure.typeAnnotation, "() -> String")
        XCTAssertNil(primitiveResultClosure.initializedValue)
        XCTAssertEqual(primitiveResultClosure.description, "let primitiveResultClosure: () -> String")
        XCTAssertTrue(primitiveResultClosure.isClosure)
        XCTAssertFalse(primitiveResultClosure.isClosureResultVoid)
        XCTAssertEqual(primitiveResultClosure.closureResult, "String")

        // tuple Result Closure
        let tupleResultClosure = declarations[8]
        XCTAssert(tupleResultClosure.attributes.isEmpty)
        XCTAssertEqual(tupleResultClosure.typeAnnotation, "() -> (String, Int)")
        XCTAssertNil(tupleResultClosure.initializedValue)
        XCTAssertEqual(tupleResultClosure.description, "let tupleResultClosure: () -> (String, Int)")
        XCTAssertTrue(tupleResultClosure.isClosure)
        XCTAssertFalse(tupleResultClosure.isClosureResultVoid)
        XCTAssertEqual(tupleResultClosure.closureResult, "(String, Int)")

        // not closure
        let notClosure = declarations[9]
        XCTAssert(notClosure.attributes.isEmpty)
        XCTAssertEqual(notClosure.typeAnnotation, "String")
        XCTAssertEqual(notClosure.description, "let notClosure: String = \"\"")
        XCTAssertFalse(notClosure.isClosure)
        XCTAssertFalse(notClosure.isClosureInputVoid)
        XCTAssertFalse(notClosure.isClosureResultVoid)
        XCTAssertEqual(notClosure.closureInput, "")
        XCTAssertEqual(notClosure.closureResult, "")
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

