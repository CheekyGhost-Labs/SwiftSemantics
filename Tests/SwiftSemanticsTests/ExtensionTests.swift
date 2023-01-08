@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class ExtensionTests: XCTestCase {
    func testExtensionDeclarationWithGenericRequirements() throws {
        let source = #"""
        extension Array where Element == String, Element: StringProtocol {}
        """#

        let declarations = try SyntaxParser.declarations(of: Extension.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let declaration = declarations.first!

        XCTAssert(declaration.attributes.isEmpty)
        XCTAssertEqual(declaration.extendedType, "Array")
        XCTAssertEqual(declaration.genericRequirements.map { $0.description }, ["Element == String", "Element: StringProtocol"])
    }

    func testFunctionDeclarationWithinExtension() throws {
        let source = #"""
        extension Collection {
            var hasAny: Bool { !isEmpty }
        }
        """#
        let extensions = try SyntaxParser.declarations(of: Extension.self, source: source)
        XCTAssertEqual(extensions.count, 1)

        let properties = try SyntaxParser.declarations(of: Variable.self, source: source)
        XCTAssertEqual(properties.count, 1)
        XCTAssertEqual(properties[0].parent, Parent(keyword: "extension", name: "Collection"))
    }

    func testFunctionDeclarationWithinConstrainedExtension() throws {
        let source = #"""
        extension Collection where Element: Comparable {
            func hasAny(lessThan element: Element) -> Bool {
                guard !isEmpty else { return false }
                return sorted().first < element
            }
        }
        """#

        let extensions = try SyntaxParser.declarations(of: Extension.self, source: source)
        XCTAssertEqual(extensions.count, 1)
        XCTAssertEqual(extensions[0].genericRequirements.count, 1)
        XCTAssertEqual(extensions[0].genericRequirements[0].leftTypeIdentifier, "Element")
        XCTAssertEqual(extensions[0].genericRequirements[0].rightTypeIdentifier, "Comparable")

        let functions = try SyntaxParser.declarations(of: Function.self, source: source)
        XCTAssertEqual(functions.count, 1)
        XCTAssertEqual(functions[0].parent, Parent(keyword: "extension", name: "Collection"))
    }

    func testinheritanceInConstrainedExtension() throws {
        let source = #"""
        extension Collection: Hashable where Element: Hashable {}
        """#

        let extensions = try SyntaxParser.declarations(of: Extension.self, source: source)
        XCTAssertEqual(extensions.count, 1)

        XCTAssertEqual(extensions[0].genericRequirements.count, 1)
        XCTAssertEqual(extensions[0].genericRequirements[0].leftTypeIdentifier, "Element")
        XCTAssertEqual(extensions[0].genericRequirements[0].rightTypeIdentifier, "Hashable")

        XCTAssertEqual(extensions[0].inheritance.count, 1)
        XCTAssertEqual(extensions[0].inheritance[0], "Hashable")
    }

    func testSourceLocations() throws {
        let source = #"""
        extension Collection where Element: Comparable {
            func hasAny(lessThan element: Element) -> Bool {
                guard !isEmpty else { return false }
                return sorted().first < element
            }
        }
          extension String {
            enum Sample {
            }
          }
        """#

        let declarations = try SyntaxParser.declarations(of: Extension.self, source: source)

        XCTAssertEqual(declarations.count, 2)
        XCTAssertEqual(declarations[0].startLocation.line, 0)
        XCTAssertEqual(declarations[0].endLocation.line, 5)
        XCTAssertEqual(declarations[0].startLocation.column, 0)
        XCTAssertEqual(declarations[0].endLocation.column, 1)
        XCTAssertEqual(declarations[0].startLocation.utf8Offset, 0)
        XCTAssertEqual(declarations[0].endLocation.utf8Offset, 194)
        XCTAssertEqual(
            declarations[0].extractFromSource(source),
            "extension Collection where Element: Comparable {\n    func hasAny(lessThan element: Element) -> Bool {\n        guard !isEmpty else { return false }\n        return sorted().first < element\n    }\n}"
        )
        XCTAssertEqual(declarations[0].startLocation.column, 0)
        XCTAssertEqual(declarations[0].endLocation.column, 1)
        XCTAssertEqual(declarations[1].startLocation.line, 6)
        XCTAssertEqual(declarations[1].endLocation.line, 9)
        XCTAssertEqual(declarations[1].startLocation.column, 2)
        XCTAssertEqual(declarations[1].endLocation.column, 3)
        XCTAssertEqual(declarations[1].startLocation.utf8Offset, 197)
        XCTAssertEqual(declarations[1].endLocation.utf8Offset, 243)
        XCTAssertEqual(
            declarations[1].extractFromSource(source),
            "extension String {\n    enum Sample {\n    }\n  }"
        )
    }

    static var allTests = [
        ("testExtensionDeclarationWithGenericRequirements", testExtensionDeclarationWithGenericRequirements),
        ("testFunctionDeclarationWithinExtension", testFunctionDeclarationWithinExtension),
        ("testFunctionDeclarationWithinConstrainedExtension", testFunctionDeclarationWithinConstrainedExtension),
        ("testinheritanceInConstrainedExtension", testinheritanceInConstrainedExtension),
    ]
}

