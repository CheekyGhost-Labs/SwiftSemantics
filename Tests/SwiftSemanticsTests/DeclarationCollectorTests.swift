@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntaxParser
import XCTest

final class DeclarationCollectorTests: XCTestCase {

    func testDeclarationCollector() throws {
        let source = #"""
        import UIKit

        class ViewController: UIViewController, UITableViewDelegate {
            enum Section: Int {
                case summary, people, places
            }

            var people: [People], places: [Place]

            @IBOutlet private(set) var tableView: UITableView!

            func sampleMethod() -> String {
                return ""
            }

            class NestedClass {
                enum Section: Int {
                    case summary, people, places
                }

                struct NestedStruct {
                    var sample: String = ""
                }

                var people: [People]

                func sampleMethod() -> String {
                    return ""
                }
            }
        }

        extension ViewController {
            func viewControllerMethod()
        }

        extension ViewController.NestedStruct {
            func sampleNested()
        }

        """#

        let collector = DeclarationCollector()
        let tree = try SyntaxParser.parse(source: source)
        collector.walk(tree)

        let viewControllerParent = Parent(keyword: "class", name: "ViewController")
        let nestedClassParent = Parent(keyword: "class", name: "NestedClass")
        let nestedStructParent = Parent(keyword: "struct", name: "NestedStruct")
        let nestedStructExtensionParent = Parent(keyword: "extension", name: "ViewController.NestedStruct")
        let viewControllerExtensionParent = Parent(keyword: "extension", name: "ViewController")

        XCTAssertEqual(collector.imports.count, 1)
        XCTAssertEqual(collector.imports.first?.pathComponents, ["UIKit"])

        XCTAssertEqual(collector.classes.count, 2)
        XCTAssertEqual(collector.classes.first?.name, "ViewController")
        XCTAssertEqual(collector.classes.first?.inheritance, ["UIViewController", "UITableViewDelegate"])
        XCTAssertEqual(collector.classes.last?.name, "NestedClass")
        XCTAssertEqual(collector.classes.last?.inheritance, [])
        XCTAssertEqual(collector.classes.last?.parent, Parent(keyword: "class", name: "ViewController"))

        XCTAssertEqual(collector.enumerations.count, 2)
        XCTAssertEqual(collector.enumerations.first?.name, "Section")
        XCTAssertEqual(collector.enumerations.first?.inheritance, ["Int"])
        XCTAssertEqual(collector.enumerations.first?.parent, viewControllerParent)
        XCTAssertEqual(collector.enumerations.last?.name, "Section")
        XCTAssertEqual(collector.enumerations.last?.inheritance, ["Int"])
        XCTAssertEqual(collector.enumerations.last?.parent, nestedClassParent)

        XCTAssertEqual(collector.enumerationCases.count, 6)
        XCTAssertEqual(collector.enumerationCases.map { $0.name }, ["summary", "people", "places", "summary", "people", "places"])

        XCTAssertEqual(collector.structures.count, 1)
        XCTAssertEqual(collector.structures[0].name, "NestedStruct")
        XCTAssertEqual(collector.structures[0].parent, nestedClassParent)

        XCTAssertEqual(collector.variables.count, 5)
        XCTAssertEqual(collector.variables[0].name, "people")
        XCTAssertEqual(collector.variables[0].typeAnnotation, "[People]")
        XCTAssertEqual(collector.variables[0].parent, viewControllerParent)
        XCTAssertEqual(collector.variables[1].name, "places")
        XCTAssertEqual(collector.variables[1].typeAnnotation, "[Place]")
        XCTAssertEqual(collector.variables[1].parent, viewControllerParent)
        XCTAssertEqual(collector.variables[2].name, "tableView")
        XCTAssertEqual(collector.variables[2].typeAnnotation, "UITableView!")
        XCTAssertEqual(collector.variables[2].parent, viewControllerParent)
        XCTAssertEqual(collector.variables[2].attributes.first?.name, "IBOutlet")
        XCTAssertEqual(collector.variables[2].modifiers.first?.name, "private")
        XCTAssertEqual(collector.variables[2].modifiers.first?.detail, "set")
        XCTAssertEqual(collector.variables[3].name, "sample")
        XCTAssertEqual(collector.variables[3].typeAnnotation, "String")
        XCTAssertEqual(collector.variables[3].parent, nestedStructParent)
        XCTAssertEqual(collector.variables[3].initializedValue, "\"\"")
        XCTAssertEqual(collector.variables[4].name, "people")
        XCTAssertEqual(collector.variables[4].typeAnnotation, "[People]")
        XCTAssertEqual(collector.variables[4].parent, nestedClassParent)

        XCTAssertEqual(collector.functions.count, 4)
        XCTAssertEqual(collector.functions[0].identifier, "sampleMethod")
        XCTAssertEqual(collector.functions[0].parent, viewControllerParent)
        XCTAssertEqual(collector.functions[1].identifier, "sampleMethod")
        XCTAssertEqual(collector.functions[1].parent, nestedClassParent)
        XCTAssertEqual(collector.functions[2].identifier, "viewControllerMethod")
        XCTAssertEqual(collector.functions[2].parent, viewControllerExtensionParent)
        XCTAssertEqual(collector.functions[3].identifier, "sampleNested")
        XCTAssertEqual(collector.functions[3].parent, nestedStructExtensionParent)
    }

    static var allTests = [
        ("testDeclarationCollector", testDeclarationCollector),
    ]
}

