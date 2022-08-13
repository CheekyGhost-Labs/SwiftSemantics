@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class StructureTests: XCTestCase {
    func testNestedStructureDeclarations() throws {
        let source = #"""
        struct A { struct B { struct C { } } }
        """#

        let declarations = try SyntaxParser.declarations(of: Structure.self, source: source)
        XCTAssertEqual(declarations.count, 3)

        XCTAssertEqual(declarations[0].name, "A")
        XCTAssertNil(declarations[0].parent)
        XCTAssertEqual(declarations[1].name, "B")
        XCTAssertEqual(declarations[1].parent, Parent(keyword: "struct", name: "A"))
        XCTAssertEqual(declarations[2].name, "C")
        XCTAssertEqual(declarations[2].parent, Parent(keyword: "struct", name: "B"))
    }

    static var allTests = [
        ("testNestedStructureDeclarations", testNestedStructureDeclarations),
    ]
}
