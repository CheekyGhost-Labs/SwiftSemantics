@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class ConditionalCompilationBlockTests: XCTestCase {
    func testConditionalCompilationBlock() throws {
        let source = #"""
        #if compiler(>=5) && os(Linux)
        enum A {}
        #elseif swift(>=4.2)
        enum B {}
        #else
        enum C {}
        #endif
        """#

        let declarations = try SyntaxParser.declarations(of: ConditionalCompilationBlock.self, source: source)
        XCTAssertEqual(declarations.count, 1)
        let conditionalCompilationBlock = declarations.first!

        XCTAssertEqual(conditionalCompilationBlock.branches.count, 3)

        XCTAssertEqual(conditionalCompilationBlock.branches[0].keyword, "#if")
        XCTAssertEqual(conditionalCompilationBlock.branches[0].condition, "compiler(>=5) && os(Linux)")

        XCTAssertEqual(conditionalCompilationBlock.branches[1].keyword, "#elseif")
        XCTAssertEqual(conditionalCompilationBlock.branches[1].condition, "swift(>=4.2)")

        XCTAssertEqual(conditionalCompilationBlock.branches[2].keyword, "#else")
        XCTAssertNil(conditionalCompilationBlock.branches[2].condition)
    }

    func testSourceLocations() throws {
        let source = #"""
        #if compiler(>=5) && os(Linux)
        enum A {}
        #elseif swift(>=4.2)
        enum B {}
        #else
        enum C {}
        #endif
            #if compiler(>=5) && os(Linux)
                enum B {}
            #else
            #endif
        struct Sample {}
        """#

        let declarations = try SyntaxParser.declarations(of: ConditionalCompilationBlock.self, source: source)

        XCTAssertEqual(declarations.count, 2)
        XCTAssertEqual(declarations[0].startLocation.line, 0)
        XCTAssertEqual(declarations[0].endLocation.line, 6)
        XCTAssertEqual(declarations[0].startLocation.column, 0)
        XCTAssertEqual(declarations[0].endLocation.column, 6)
        XCTAssertEqual(declarations[1].startLocation.line, 7)
        XCTAssertEqual(declarations[1].endLocation.line, 10)
        XCTAssertEqual(declarations[1].startLocation.column, 4)
        XCTAssertEqual(declarations[1].endLocation.column, 10)
    }

    static var allTests = [
        ("testConditionalCompilationBlock", testConditionalCompilationBlock),
    ]
}

