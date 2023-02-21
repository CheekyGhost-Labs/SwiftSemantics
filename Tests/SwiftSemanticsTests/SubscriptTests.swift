@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class SubscriptTests: XCTestCase {
    func testSubscriptDeclaration() throws {
        let source = #"""
        subscript(index: Int) -> Int?

        struct SampleStruct {
            subscript(key: String) -> String?
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Subscript.self, source: source)
        XCTAssertEqual(declarations.count, 2)

        XCTAssert(declarations[0].attributes.isEmpty)
        XCTAssertEqual(declarations[0].indices.count, 1)
        XCTAssertEqual(declarations[0].indices[0].name, "index")
        XCTAssertEqual(declarations[0].indices[0].type, "Int")
        XCTAssertEqual(declarations[0].returnType, "Int?")
        XCTAssertEqual(declarations[0].description, "subscript(index: Int) -> Int?")
        XCTAssertNil(declarations[0].parent)

        XCTAssert(declarations[1].attributes.isEmpty)
        XCTAssertEqual(declarations[1].indices.count, 1)
        XCTAssertEqual(declarations[1].indices[0].name, "key")
        XCTAssertEqual(declarations[1].indices[0].type, "String")
        XCTAssertEqual(declarations[1].returnType, "String?")
        XCTAssertEqual(declarations[1].description, "subscript(key: String) -> String?")
        XCTAssertEqual(declarations[1].parent, Parent(keyword: "struct", name: "SampleStruct"))
    }

    func testSubscriptDeclarationWithGenericParameters() throws {
        let source = #"""
        subscript<T: Any>(index: T) -> Int?

        struct SampleStruct {
            subscript<T: Any>(key: T) -> String?
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Subscript.self, source: source)
        XCTAssertEqual(declarations.count, 2)

        XCTAssert(declarations[0].attributes.isEmpty)
        XCTAssertEqual(declarations[0].indices.count, 1)
        XCTAssertEqual(declarations[0].indices[0].name, "index")
        XCTAssertEqual(declarations[0].indices[0].type, "T")
        XCTAssertEqual(declarations[0].returnType, "Int?")
        XCTAssertEqual(declarations[0].description, "subscript<T: Any>(index: T) -> Int?")
        XCTAssertNil(declarations[0].parent)

        XCTAssert(declarations[1].attributes.isEmpty)
        XCTAssertEqual(declarations[1].indices.count, 1)
        XCTAssertEqual(declarations[1].indices[0].name, "key")
        XCTAssertEqual(declarations[1].indices[0].type, "T")
        XCTAssertEqual(declarations[1].returnType, "String?")
        XCTAssertEqual(declarations[1].description, "subscript<T: Any>(key: T) -> String?")
        XCTAssertEqual(declarations[1].parent, Parent(keyword: "struct", name: "SampleStruct"))
    }

    func testSubscriptDeclarationWithGenericRequirements() throws {
        let source = #"""
        subscript<T: Any>(index: T) -> Int? where T: NSObject

        struct SampleStruct {
            subscript<T: Any>(key: T) -> String? where T: NSObject
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Subscript.self, source: source)
        XCTAssertEqual(declarations.count, 2)

        XCTAssert(declarations[0].attributes.isEmpty)
        XCTAssertEqual(declarations[0].indices.count, 1)
        XCTAssertEqual(declarations[0].indices[0].name, "index")
        XCTAssertEqual(declarations[0].indices[0].type, "T")
        XCTAssertEqual(declarations[0].returnType, "Int?")
        XCTAssertEqual(declarations[0].description, "subscript<T: Any>(index: T) -> Int? where T: NSObject")
        XCTAssertNil(declarations[0].parent)

        XCTAssert(declarations[1].attributes.isEmpty)
        XCTAssertEqual(declarations[1].indices.count, 1)
        XCTAssertEqual(declarations[1].indices[0].name, "key")
        XCTAssertEqual(declarations[1].indices[0].type, "T")
        XCTAssertEqual(declarations[1].returnType, "String?")
        XCTAssertEqual(declarations[1].description, "subscript<T: Any>(key: T) -> String? where T: NSObject")
        XCTAssertEqual(declarations[1].parent, Parent(keyword: "struct", name: "SampleStruct"))
    }

    func testSourceLocations() throws {
        let source = #"""
        subscript<T: Any>(index: T) -> Int? where T: NSObject

        struct SampleStruct {
            subscript(key: String) -> String?
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Subscript.self, source: source)

        XCTAssertEqual(declarations.count, 2)
        XCTAssertEqual(declarations[0].startLocation.line, 0)
        XCTAssertEqual(declarations[0].startLocation.utf8Offset, 0)
        XCTAssertEqual(declarations[0].endLocation.line, 0)
        XCTAssertEqual(declarations[0].endLocation.utf8Offset, 53)
        XCTAssertEqual(declarations[0].startLocation.column, 0)
        XCTAssertEqual(declarations[0].endLocation.column, 53)
        XCTAssertEqual(
            declarations[0].extractFromSource(source),
            "subscript<T: Any>(index: T) -> Int? where T: NSObject"
        )
        XCTAssertEqual(declarations[1].startLocation.line, 3)
        XCTAssertEqual(declarations[1].startLocation.utf8Offset, 81)
        XCTAssertEqual(declarations[1].endLocation.line, 3)
        XCTAssertEqual(declarations[1].endLocation.utf8Offset, 114)
        XCTAssertEqual(declarations[1].startLocation.column, 4)
        XCTAssertEqual(declarations[1].endLocation.column, 37)
        XCTAssertEqual(
            declarations[1].extractFromSource(source),
            "subscript(key: String) -> String?"
        )
    }

    static var allTests = [
        ("testSubscriptDeclaration", testSubscriptDeclaration),
        ("testSubscriptDeclarationWithGenericParameters", testSubscriptDeclarationWithGenericParameters),
        ("testSubscriptDeclarationWithGenericRequirements", testSubscriptDeclarationWithGenericRequirements)
    ]
}
