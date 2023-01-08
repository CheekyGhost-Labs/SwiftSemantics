@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class OperatorTests: XCTestCase {
    func testSimpleOperatorDeclaration() throws {
        let source = #"""
        prefix operator +++
        """#

        let declarations = try SyntaxParser.declarations(of: Operator.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.modifiers.count, 1)
        XCTAssertEqual(declaration.modifiers.first?.name, "prefix")
        XCTAssertEqual(declaration.kind, .prefix)
        XCTAssertEqual(declaration.name, "+++")
        XCTAssertNil(declaration.parent)
    }

    func testSimpleOperatorWithParent() throws {
        let source = #"""
        struct Sample {
            prefix operator +++
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Operator.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.modifiers.count, 1)
        XCTAssertEqual(declaration.modifiers.first?.name, "prefix")
        XCTAssertEqual(declaration.kind, .prefix)
        XCTAssertEqual(declaration.name, "+++")
        XCTAssertEqual(declaration.parent, Parent(keyword: "struct", name: "Sample"))
    }

    func testSourceLocations() throws {
        let source = #"""
        prefix operator +++
        struct Sample {
            prefix operator +++
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Operator.self, source: source)

        XCTAssertEqual(declarations.count, 2)
        XCTAssertEqual(declarations[0].startLocation.line, 0)
        XCTAssertEqual(declarations[0].endLocation.line, 0)
        XCTAssertEqual(declarations[0].startLocation.column, 0)
        XCTAssertEqual(declarations[0].endLocation.column, 19)
        XCTAssertEqual(declarations[0].startLocation.utf8Offset, 0)
        XCTAssertEqual(declarations[0].endLocation.utf8Offset, 19)
        XCTAssertEqual(declarations[0].extractFromSource(source), "prefix operator +++")
        XCTAssertEqual(declarations[1].startLocation.line, 2)
        XCTAssertEqual(declarations[1].endLocation.line, 2)
        XCTAssertEqual(declarations[1].startLocation.column, 4)
        XCTAssertEqual(declarations[1].endLocation.column, 23)
        XCTAssertEqual(declarations[1].startLocation.utf8Offset, 40)
        XCTAssertEqual(declarations[1].endLocation.utf8Offset, 59)
        XCTAssertEqual(declarations[1].extractFromSource(source), "prefix operator +++")
    }

    static var allTests = [
        ("testSimpleOperatorDeclaration", testSimpleOperatorDeclaration),
    ]
}

