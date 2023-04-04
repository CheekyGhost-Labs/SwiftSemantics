@testable import SwiftSemantics
import SwiftSyntax
import SwiftSyntaxParser
import XCTest

final class ProtocolTests: XCTestCase {
    func testProtocolDeclaration() throws {
        let source = #"""
        public protocol P {}
        """#

        let declarations = try SyntaxParser.declarations(of: Protocol.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.name, "P")
    }

    func testProtocolDeclarationWithPrimaryAssociatedTypes() throws {
        let source = #"""
        public protocol P<Parameter, Object> {}
        public protocol P<Parameter> {}
        public protocol P {}
        """#

        let declarations = try SyntaxParser.declarations(of: Protocol.self, source: source)
        XCTAssertEqual(declarations.count, 3)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declarations[0].primaryAssociatedTypes, ["Parameter", "Object"])
        XCTAssertEqual(declarations[1].primaryAssociatedTypes, ["Parameter"])
        XCTAssertEqual(declarations[2].primaryAssociatedTypes, [])
    }

    func testSourceLocations() throws {
        let source = #"""
        public protocol A {}
        public protocol B {}
        public protocol C {}
        """#

        let declarations = try SyntaxParser.declarations(of: Protocol.self, source: source)

        XCTAssertEqual(declarations.count, 3)
        XCTAssertEqual(declarations[0].startLocation.line, 0)
        XCTAssertEqual(declarations[0].endLocation.line, 0)
        XCTAssertEqual(declarations[0].startLocation.column, 0)
        XCTAssertEqual(declarations[0].endLocation.column, 20)
        XCTAssertEqual(declarations[0].startLocation.utf8Offset, 0)
        XCTAssertEqual(declarations[0].endLocation.utf8Offset, 20)
        XCTAssertEqual(declarations[0].extractFromSource(source), "public protocol A {}")
        XCTAssertEqual(declarations[1].startLocation.line, 1)
        XCTAssertEqual(declarations[1].endLocation.line, 1)
        XCTAssertEqual(declarations[1].startLocation.column, 0)
        XCTAssertEqual(declarations[1].endLocation.column, 20)
        XCTAssertEqual(declarations[1].startLocation.utf8Offset, 21)
        XCTAssertEqual(declarations[1].endLocation.utf8Offset, 41)
        XCTAssertEqual(declarations[1].extractFromSource(source), "public protocol B {}")
        XCTAssertEqual(declarations[2].startLocation.line, 2)
        XCTAssertEqual(declarations[2].endLocation.line, 2)
        XCTAssertEqual(declarations[2].startLocation.column, 0)
        XCTAssertEqual(declarations[2].endLocation.column, 20)
        XCTAssertEqual(declarations[2].startLocation.utf8Offset, 42)
        XCTAssertEqual(declarations[2].endLocation.utf8Offset, 62)
        XCTAssertEqual(declarations[2].extractFromSource(source), "public protocol C {}")
    }

    static var allTests = [
        ("testProtocolDeclaration", testProtocolDeclaration),
    ]
}

