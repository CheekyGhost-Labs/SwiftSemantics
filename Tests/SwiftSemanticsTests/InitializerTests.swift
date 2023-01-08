@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class InitializerTests: XCTestCase {
    func testInitializerDeclaration() throws {
        let source = #"""
        public class Person { public init?(names: String...) throws }
        """#

        let declarations = try SyntaxParser.declarations(of: Initializer.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let initializer = declarations.first!

        XCTAssert(initializer.attributes.isEmpty)
        XCTAssertEqual(initializer.keyword, "init")
        XCTAssertEqual(initializer.parameters.count, 1)
        XCTAssertEqual(initializer.parameters[0].name, "names")
        XCTAssertNil(initializer.parameters[0].secondName)
        XCTAssertEqual(initializer.parameters[0].type, "String")
        XCTAssertTrue(initializer.parameters[0].variadic)
        XCTAssertEqual(initializer.throwsOrRethrowsKeyword, "throws")
        XCTAssertEqual(initializer.parent, Parent(modifiers: [Modifier(name: "public", detail: nil)], keyword: "class", name: "Person"))
    }

    func testSourceLocations() throws {
        let source = #"""
        // File Header
        public class Person {
            public init?(names: String...) throws {
                // no-op
            }
            public init(age: Int) {}
        }
        """#

        let declarations = try SyntaxParser.declarations(of: Initializer.self, source: source)

        XCTAssertEqual(declarations.count, 2)
        XCTAssertEqual(declarations[0].startLocation.line, 2)
        XCTAssertEqual(declarations[0].endLocation.line, 4)
        XCTAssertEqual(declarations[0].startLocation.column, 4)
        XCTAssertEqual(declarations[0].endLocation.column, 5)
        XCTAssertEqual(declarations[0].startLocation.utf8Offset, 41)
        XCTAssertEqual(declarations[0].endLocation.utf8Offset, 103)
        XCTAssertEqual(declarations[0].extractFromSource(source), "public init?(names: String...) throws {\n        // no-op\n    }")
        XCTAssertEqual(declarations[1].startLocation.line, 5)
        XCTAssertEqual(declarations[1].endLocation.line, 5)
        XCTAssertEqual(declarations[1].startLocation.column, 4)
        XCTAssertEqual(declarations[1].endLocation.column, 28)
        XCTAssertEqual(declarations[1].startLocation.utf8Offset, 108)
        XCTAssertEqual(declarations[1].endLocation.utf8Offset, 132)
        XCTAssertEqual(declarations[1].extractFromSource(source), "public init(age: Int) {}")

    }

    static var allTests = [
        ("testInitializerDeclaration", testInitializerDeclaration),
    ]
}

