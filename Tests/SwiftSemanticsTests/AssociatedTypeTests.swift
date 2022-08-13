@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class AssociatedTypeTests: XCTestCase {
    func testAssociatedTypeDeclaration() throws {
        let source = #"""
        associatedtype T
        protocol SampleProtocol {
            associatedtype S
        }
        """#

        let declarations = try SyntaxParser.declarations(of: AssociatedType.self, source: source)
        XCTAssertEqual(declarations.count, 2)

        XCTAssertEqual(declarations[0].attributes.count, 0)
        XCTAssertEqual(declarations[0].name, "T")
        XCTAssertEqual(declarations[0].description, "associatedtype T")
        XCTAssertNil(declarations[0].parent)
        XCTAssertEqual(declarations[1].attributes.count, 0)
        XCTAssertEqual(declarations[1].name, "S")
        XCTAssertEqual(declarations[1].description, "associatedtype S")
        XCTAssertEqual(declarations[1].parent, Parent(keyword: "protocol", name: "SampleProtocol"))
    }

    static var allTests = [
        ("testAssociatedTypeDeclaration", testAssociatedTypeDeclaration),
    ]
}

