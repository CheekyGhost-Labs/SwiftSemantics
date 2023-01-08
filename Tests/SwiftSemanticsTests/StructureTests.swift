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

    func testSourceLocations() throws {
        let source = #"""
        struct A { struct B { struct C { } } }
        struct D {
            struct E {
                struct C { }
            }
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Structure.self, source: source)

        XCTAssertEqual(declarations.count, 6)
        XCTAssertEqual(declarations[0].startLocation.line, 0)
        XCTAssertEqual(declarations[0].endLocation.line, 0)
        XCTAssertEqual(declarations[0].startLocation.column, 0)
        XCTAssertEqual(declarations[0].endLocation.column, 38)
        XCTAssertEqual(declarations[0].startLocation.utf8Offset, 0)
        XCTAssertEqual(declarations[0].endLocation.utf8Offset, 38)
        XCTAssertEqual(declarations[0].extractFromSource(source), "struct A { struct B { struct C { } } }")
        XCTAssertEqual(declarations[1].startLocation.line, 0)
        XCTAssertEqual(declarations[1].endLocation.line, 0)
        XCTAssertEqual(declarations[1].startLocation.column, 11)
        XCTAssertEqual(declarations[1].endLocation.column, 36)
        XCTAssertEqual(declarations[1].startLocation.utf8Offset, 11)
        XCTAssertEqual(declarations[1].endLocation.utf8Offset, 36)
        XCTAssertEqual(declarations[1].extractFromSource(source), "struct B { struct C { } }")
        XCTAssertEqual(declarations[2].startLocation.line, 0)
        XCTAssertEqual(declarations[2].endLocation.line, 0)
        XCTAssertEqual(declarations[2].startLocation.column, 22)
        XCTAssertEqual(declarations[2].endLocation.column, 34)
        XCTAssertEqual(declarations[2].startLocation.utf8Offset, 22)
        XCTAssertEqual(declarations[2].endLocation.utf8Offset, 34)
        XCTAssertEqual(declarations[2].extractFromSource(source), "struct C { }")
        XCTAssertEqual(declarations[3].startLocation.line, 1)
        XCTAssertEqual(declarations[3].endLocation.line, 5)
        XCTAssertEqual(declarations[3].startLocation.column, 0)
        XCTAssertEqual(declarations[3].endLocation.column, 1)
        XCTAssertEqual(declarations[3].startLocation.utf8Offset, 39)
        XCTAssertEqual(declarations[3].endLocation.utf8Offset, 93)
        XCTAssertEqual(declarations[3].extractFromSource(source), "struct D {\n    struct E {\n        struct C { }\n    }\n}")
        XCTAssertEqual(declarations[4].startLocation.line, 2)
        XCTAssertEqual(declarations[4].endLocation.line, 4)
        XCTAssertEqual(declarations[4].startLocation.column, 4)
        XCTAssertEqual(declarations[4].endLocation.column, 5)
        XCTAssertEqual(declarations[4].startLocation.utf8Offset, 54)
        XCTAssertEqual(declarations[4].endLocation.utf8Offset, 91)
        XCTAssertEqual(declarations[4].extractFromSource(source), "struct E {\n        struct C { }\n    }")
        XCTAssertEqual(declarations[5].startLocation.line, 3)
        XCTAssertEqual(declarations[5].endLocation.line, 3)
        XCTAssertEqual(declarations[5].startLocation.column, 8)
        XCTAssertEqual(declarations[5].endLocation.column, 20)
        XCTAssertEqual(declarations[5].startLocation.utf8Offset, 73)
        XCTAssertEqual(declarations[5].endLocation.utf8Offset, 85)
        XCTAssertEqual(declarations[5].extractFromSource(source), "struct C { }")
    }

    static var allTests = [
        ("testNestedStructureDeclarations", testNestedStructureDeclarations),
    ]
}
