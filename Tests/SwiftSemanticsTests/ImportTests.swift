@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class ImportTests: XCTestCase {
    func testSimpleImportDeclaration() throws {
        let source = #"""
        import Foundation
        """#

        let declarations = try SyntaxParser.declarations(of: Import.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertNil(declaration.kind)
        XCTAssertEqual(declaration.pathComponents, ["Foundation"])
        XCTAssertEqual(declaration.description, source)
    }

    func testComplexImportDeclaration() throws {
        let source = #"""
        import struct SwiftSemantics.Import
        """#

        let declarations = try SyntaxParser.declarations(of: Import.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.kind, "struct")
        XCTAssertEqual(declaration.pathComponents, ["SwiftSemantics", "Import"])
        XCTAssertEqual(declaration.description, source)
    }

    func testSourceLocations() throws {
        let source = #"""
        // File Header
        import Foundation
        import struct SwiftSemantics.Import
        struct Sample {
            // no-contents
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Import.self, source: source)

        XCTAssertEqual(declarations.count, 2)
        XCTAssertEqual(declarations[0].startLocation.line, 1)
        XCTAssertEqual(declarations[0].endLocation.line, 1)
        XCTAssertEqual(declarations[0].startLocation.column, 0)
        XCTAssertEqual(declarations[0].endLocation.column, 17)
        XCTAssertEqual(declarations[0].startLocation.utf8Offset, 15)
        XCTAssertEqual(declarations[0].endLocation.utf8Offset, 32)
        XCTAssertEqual(declarations[0].extractFromSource(source), "import Foundation")
        XCTAssertEqual(declarations[1].startLocation.line, 2)
        XCTAssertEqual(declarations[1].endLocation.line, 2)
        XCTAssertEqual(declarations[1].startLocation.column, 0)
        XCTAssertEqual(declarations[1].endLocation.column, 35)
        XCTAssertEqual(declarations[1].startLocation.utf8Offset, 33)
        XCTAssertEqual(declarations[1].endLocation.utf8Offset, 68)
        XCTAssertEqual(declarations[1].extractFromSource(source), "import struct SwiftSemantics.Import")
    }

    static var allTests = [
        ("testSimpleImportDeclaration", testSimpleImportDeclaration),
        ("testComplexImportDeclaration", testComplexImportDeclaration),
    ]
}

