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
        XCTAssertEqual(declarations[0].indices[0].firstName, "index")
        XCTAssertEqual(declarations[0].indices[0].type, "Int")
        XCTAssertEqual(declarations[0].returnType, "Int?")
        XCTAssertEqual(declarations[0].description, "subscript(index: Int) -> Int?")
        XCTAssertNil(declarations[0].parent)

        XCTAssert(declarations[1].attributes.isEmpty)
        XCTAssertEqual(declarations[1].indices.count, 1)
        XCTAssertEqual(declarations[1].indices[0].firstName, "key")
        XCTAssertEqual(declarations[1].indices[0].type, "String")
        XCTAssertEqual(declarations[1].returnType, "String?")
        XCTAssertEqual(declarations[1].description, "subscript(key: String) -> String?")
        XCTAssertEqual(declarations[1].parent, Parent(keyword: "struct", name: "SampleStruct"))
    }

    static var allTests = [
        ("testSubscriptDeclaration", testSubscriptDeclaration),
    ]
}
