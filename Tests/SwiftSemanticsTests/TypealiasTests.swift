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
    }


    func testSourceLocations() throws {
        let source = #"""
        typealias SortableArray<T: Comparable> = Array<T>
        struct SampleStruct {
            typealias SomeThing<T> = (T, String) -> String where T: Numeric
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Typealias.self, source: source)

        XCTAssertEqual(declarations.count, 2)
        XCTAssertEqual(declarations[0].startLocation.line, 0)
        XCTAssertEqual(declarations[0].startLocation.utf8Offset, 0)
        XCTAssertEqual(declarations[0].endLocation.line, 0)
        XCTAssertEqual(declarations[0].endLocation.utf8Offset, 49)
        XCTAssertEqual(declarations[0].startLocation.column, 0)
        XCTAssertEqual(declarations[0].endLocation.column, 49)
        XCTAssertEqual(
            declarations[0].extractFromSource(source),
            "typealias SortableArray<T: Comparable> = Array<T>"
        )
        XCTAssertEqual(declarations[1].startLocation.line, 2)
        XCTAssertEqual(declarations[1].startLocation.utf8Offset, 76)
        XCTAssertEqual(declarations[1].endLocation.line, 2)
        XCTAssertEqual(declarations[1].endLocation.utf8Offset, 139)
        XCTAssertEqual(declarations[1].startLocation.column, 4)
        XCTAssertEqual(declarations[1].endLocation.column, 67)
        XCTAssertEqual(
            declarations[1].extractFromSource(source),
            "typealias SomeThing<T> = (T, String) -> String where T: Numeric"
        )
    }
}
