@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class TypealiasTests: XCTestCase {
    func testTypealiasDeclarationsWithGenericParameter() throws {
        let source = #"""
        typealias SortableArray<T: Comparable> = Array<T>
        """#

        let declarations = try SyntaxParser.declarations(of: Typealias.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let `typealias` = declarations.first!

        XCTAssertEqual(`typealias`.attributes.count, 0)
        XCTAssertEqual(`typealias`.name, "SortableArray")
        XCTAssertEqual(`typealias`.genericParameters.count, 1)
        XCTAssertEqual(`typealias`.genericParameters[0].name, "T")
        XCTAssertEqual(`typealias`.genericParameters[0].type, "Comparable")
        XCTAssertEqual(`typealias`.initializedType, "Array<T>")
        XCTAssertNil(`typealias`.parent)
    }

    func testTypealiasDeclarationsWithGenericRequirement() throws {
        let source = #"""
        typealias ArrayOfNumbers<T> = Array<T> where T: Numeric
        """#

        let declarations = try SyntaxParser.declarations(of: Typealias.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let `typealias` = declarations.first!

        XCTAssertEqual(`typealias`.attributes.count, 0)
        XCTAssertEqual(`typealias`.name, "ArrayOfNumbers")
        XCTAssertEqual(`typealias`.genericParameters.count, 1)
        XCTAssertEqual(`typealias`.genericParameters[0].name, "T")
        XCTAssertNil(`typealias`.genericParameters[0].type)
        XCTAssertEqual(`typealias`.initializedType, "Array<T>")
        XCTAssertEqual(`typealias`.genericRequirements.count, 1)
        XCTAssertEqual(`typealias`.genericRequirements[0].leftTypeIdentifier, "T")
        XCTAssertEqual(`typealias`.genericRequirements[0].relation, .conformance)
        XCTAssertEqual(`typealias`.genericRequirements[0].rightTypeIdentifier, "Numeric")
        XCTAssertNil(`typealias`.parent)
    }

    func testTypealiasDeclarationsWithParent() throws {
        let source = #"""
        struct SampleStruct {
            typealias ArrayOfNumbers<T> = Array<T> where T: Numeric
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Typealias.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let `typealias` = declarations.first!

        XCTAssertEqual(`typealias`.attributes.count, 0)
        XCTAssertEqual(`typealias`.name, "ArrayOfNumbers")
        XCTAssertEqual(`typealias`.genericParameters.count, 1)
        XCTAssertEqual(`typealias`.genericParameters[0].name, "T")
        XCTAssertNil(`typealias`.genericParameters[0].type)
        XCTAssertEqual(`typealias`.initializedType, "Array<T>")
        XCTAssertEqual(`typealias`.genericRequirements.count, 1)
        XCTAssertEqual(`typealias`.genericRequirements[0].leftTypeIdentifier, "T")
        XCTAssertEqual(`typealias`.genericRequirements[0].relation, .conformance)
        XCTAssertEqual(`typealias`.genericRequirements[0].rightTypeIdentifier, "Numeric")
        XCTAssertEqual(`typealias`.parent, Parent(keyword: "struct", name: "SampleStruct"))
    }

    func testTypealiasDeclarationsWithVoidResultClosure() throws {
        let source = #"""
        struct SampleStruct {
            typealias SomeThing<T> = (T) -> Void where T: Numeric
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Typealias.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let `typealias` = declarations.first!

        XCTAssertEqual(`typealias`.attributes.count, 0)
        XCTAssertEqual(`typealias`.name, "SomeThing")
        XCTAssertEqual(`typealias`.genericParameters.count, 1)
        XCTAssertEqual(`typealias`.genericParameters[0].name, "T")
        XCTAssertNil(`typealias`.genericParameters[0].type)
        XCTAssertEqual(`typealias`.initializedType, "(T) -> Void")
        XCTAssertEqual(`typealias`.genericRequirements.count, 1)
        XCTAssertEqual(`typealias`.genericRequirements[0].leftTypeIdentifier, "T")
        XCTAssertEqual(`typealias`.genericRequirements[0].relation, .conformance)
        XCTAssertEqual(`typealias`.genericRequirements[0].rightTypeIdentifier, "Numeric")
        XCTAssertEqual(`typealias`.parent, Parent(keyword: "struct", name: "SampleStruct"))
//        let closureType = try XCTUnwrap(`typealias`.closureType)
//        XCTAssertFalse(closureType.isVoidInput)
//        XCTAssertTrue(closureType.isVoidOutput)
//        XCTAssertEqual(closureType.rawInput, "(T)")
//        XCTAssertEqual(closureType.rawOutput, "Void")
    }

    func testTypealiasDeclarationsWithVoidInputClosure() throws {
        let source = #"""
        struct SampleStruct {
            typealias SomeThing<T> = ((Void)) -> Void where T: Numeric
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Typealias.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let `typealias` = declarations.first!

        XCTAssertEqual(`typealias`.attributes.count, 0)
        XCTAssertEqual(`typealias`.name, "SomeThing")
        XCTAssertEqual(`typealias`.genericParameters.count, 1)
        XCTAssertEqual(`typealias`.genericParameters[0].name, "T")
        XCTAssertNil(`typealias`.genericParameters[0].type)
        XCTAssertEqual(`typealias`.initializedType, "((Void)) -> Void")
        XCTAssertEqual(`typealias`.genericRequirements.count, 1)
        XCTAssertEqual(`typealias`.genericRequirements[0].leftTypeIdentifier, "T")
        XCTAssertEqual(`typealias`.genericRequirements[0].relation, .conformance)
        XCTAssertEqual(`typealias`.genericRequirements[0].rightTypeIdentifier, "Numeric")
        XCTAssertEqual(`typealias`.parent, Parent(keyword: "struct", name: "SampleStruct"))
//        let closureType = try XCTUnwrap(`typealias`.closureType)
//        XCTAssertTrue(closureType.isVoidInput)
//        XCTAssertTrue(closureType.isVoidOutput)
//        XCTAssertEqual(closureType.rawInput, "(Void)")
//        XCTAssertEqual(closureType.rawOutput, "Void")
    }

    func testTypealiasDeclarationsWithEmptyInputClosure() throws {
        let source = #"""
        struct SampleStruct {
            typealias SomeThing<T> = () -> Void where T: Numeric
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Typealias.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let `typealias` = declarations.first!

        XCTAssertEqual(`typealias`.attributes.count, 0)
        XCTAssertEqual(`typealias`.name, "SomeThing")
        XCTAssertEqual(`typealias`.genericParameters.count, 1)
        XCTAssertEqual(`typealias`.genericParameters[0].name, "T")
        XCTAssertNil(`typealias`.genericParameters[0].type)
        XCTAssertEqual(`typealias`.initializedType, "() -> Void")
        XCTAssertEqual(`typealias`.genericRequirements.count, 1)
        XCTAssertEqual(`typealias`.genericRequirements[0].leftTypeIdentifier, "T")
        XCTAssertEqual(`typealias`.genericRequirements[0].relation, .conformance)
        XCTAssertEqual(`typealias`.genericRequirements[0].rightTypeIdentifier, "Numeric")
        XCTAssertEqual(`typealias`.parent, Parent(keyword: "struct", name: "SampleStruct"))
//        let closureType = try XCTUnwrap(`typealias`.closureType)
//        XCTAssertFalse(closureType.isVoidInput)
//        XCTAssertTrue(closureType.isVoidOutput)
//        XCTAssertEqual(closureType.rawInput, "()")
//        XCTAssertEqual(closureType.rawOutput, "Void")
    }

    func testTypealiasDeclarationsWithTypeClosure() throws {
        let source = #"""
        struct SampleStruct {
            typealias SomeThing<T> = (T, String) -> String where T: Numeric
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Typealias.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let `typealias` = declarations.first!

        XCTAssertEqual(`typealias`.attributes.count, 0)
        XCTAssertEqual(`typealias`.name, "SomeThing")
        XCTAssertEqual(`typealias`.genericParameters.count, 1)
        XCTAssertEqual(`typealias`.genericParameters[0].name, "T")
        XCTAssertNil(`typealias`.genericParameters[0].type)
        XCTAssertEqual(`typealias`.initializedType, "(T, String) -> String")
        XCTAssertEqual(`typealias`.genericRequirements.count, 1)
        XCTAssertEqual(`typealias`.genericRequirements[0].leftTypeIdentifier, "T")
        XCTAssertEqual(`typealias`.genericRequirements[0].relation, .conformance)
        XCTAssertEqual(`typealias`.genericRequirements[0].rightTypeIdentifier, "Numeric")
        XCTAssertEqual(`typealias`.parent, Parent(keyword: "struct", name: "SampleStruct"))
//        let closureType = try XCTUnwrap(`typealias`.closureType)
//        XCTAssertFalse(closureType.isVoidInput)
//        XCTAssertFalse(closureType.isVoidOutput)
//        XCTAssertEqual(closureType.rawInput, "(T, String)")
//        XCTAssertEqual(closureType.rawOutput, "String")
    }

    static var allTests = [
        ("testTypealiasDeclarationsWithGenericParameter", testTypealiasDeclarationsWithGenericParameter),
        ("testTypealiasDeclarationsWithGenericRequirement", testTypealiasDeclarationsWithGenericRequirement),
    ]
}
