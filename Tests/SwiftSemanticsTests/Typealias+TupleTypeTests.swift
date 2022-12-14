@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntax
import SwiftSyntaxParser
import XCTest

final class TypealiasTupleTypeTests: XCTestCase {

    // MARK: - Tests: Closures: Void Inputs

    func test_simpleTuple() throws {
        let source = #"""
        typealias SimpleTuple = (String, Int)
        typealias SimpleTuple = (String, Int)?
        typealias SimpleTuple = ((String, Int))
        typealias SimpleTuple = ((String, Int))?
        typealias SimpleTuple = ((String, Int)?)
        """#

        let elements = try SyntaxParser.declarations(of: Typealias.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            let tupleType = try XCTUnwrap(declaration.tupleType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.initializedType, "(String, Int)")
                XCTAssertEqual(declaration.description, "typealias SimpleTuple = (String, Int)")
                XCTAssertFalse(tupleType.isOptional)
            case 1:
                XCTAssertEqual(declaration.initializedType, "(String, Int)?")
                XCTAssertEqual(declaration.description, "typealias SimpleTuple = (String, Int)?")
                XCTAssertTrue(tupleType.isOptional)
            case 2:
                XCTAssertEqual(declaration.initializedType, "((String, Int))")
                XCTAssertEqual(declaration.description, "typealias SimpleTuple = ((String, Int))")
                XCTAssertFalse(tupleType.isOptional)
            case 3:
                XCTAssertEqual(declaration.initializedType, "((String, Int))?")
                XCTAssertEqual(declaration.description, "typealias SimpleTuple = ((String, Int))?")
                XCTAssertTrue(tupleType.isOptional)
            case 4:
                XCTAssertEqual(declaration.initializedType, "((String, Int)?)")
                XCTAssertEqual(declaration.description, "typealias SimpleTuple = ((String, Int)?)")
                XCTAssertTrue(tupleType.isOptional)
            default: break
            }
            XCTAssertEqual(tupleType.arguments.count, 2)
            // String
            XCTAssertTrue(tupleType.arguments[0] is StandardParameter)
            XCTAssertNil(tupleType.arguments[0].name)
            XCTAssertNil(tupleType.arguments[0].secondName)
            XCTAssertNil(tupleType.arguments[0].preferredName)
            XCTAssertFalse(tupleType.arguments[0].isLabelOmitted)
            XCTAssertFalse(tupleType.arguments[0].variadic)
            XCTAssertFalse(tupleType.arguments[0].isOptional)
            XCTAssertFalse(tupleType.arguments[0].isInOut)
            XCTAssertEqual(tupleType.arguments[0].type, "String")
            XCTAssertEqual(tupleType.arguments[0].typeWithoutAttributes, "String")
            XCTAssertEqual(tupleType.arguments[0].description, "String")
            // Int
            XCTAssertTrue(tupleType.arguments[1] is StandardParameter)
            XCTAssertNil(tupleType.arguments[1].name)
            XCTAssertNil(tupleType.arguments[1].secondName)
            XCTAssertNil(tupleType.arguments[1].preferredName)
            XCTAssertFalse(tupleType.arguments[1].isLabelOmitted)
            XCTAssertFalse(tupleType.arguments[1].variadic)
            XCTAssertFalse(tupleType.arguments[1].isOptional)
            XCTAssertFalse(tupleType.arguments[1].isInOut)
            XCTAssertEqual(tupleType.arguments[1].type, "Int")
            XCTAssertEqual(tupleType.arguments[1].typeWithoutAttributes, "Int")
            XCTAssertEqual(tupleType.arguments[1].description, "Int")
        }
    }

    func test_namedTuple() throws {
        let source = #"""
        typealias SimpleTuple = (name: String, age: Int?)
        typealias SimpleTuple = (name: String, age: Int?)?
        typealias SimpleTuple = ((name: String, age: Int?))
        typealias SimpleTuple = ((name: String, age: Int?))?
        typealias SimpleTuple = ((name: String, age: Int?)?)
        """#

        let elements = try SyntaxParser.declarations(of: Typealias.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            let tupleType = try XCTUnwrap(declaration.tupleType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.initializedType, "(name: String, age: Int?)")
                XCTAssertEqual(declaration.description, "typealias SimpleTuple = (name: String, age: Int?)")
                XCTAssertFalse(tupleType.isOptional)
            case 1:
                XCTAssertEqual(declaration.initializedType, "(name: String, age: Int?)?")
                XCTAssertEqual(declaration.description, "typealias SimpleTuple = (name: String, age: Int?)?")
                XCTAssertTrue(tupleType.isOptional)
            case 2:
                XCTAssertEqual(declaration.initializedType, "((name: String, age: Int?))")
                XCTAssertEqual(declaration.description, "typealias SimpleTuple = ((name: String, age: Int?))")
                XCTAssertFalse(tupleType.isOptional)
            case 3:
                XCTAssertEqual(declaration.initializedType, "((name: String, age: Int?))?")
                XCTAssertEqual(declaration.description, "typealias SimpleTuple = ((name: String, age: Int?))?")
                XCTAssertTrue(tupleType.isOptional)
            case 4:
                XCTAssertEqual(declaration.initializedType, "((name: String, age: Int?)?)")
                XCTAssertEqual(declaration.description, "typealias SimpleTuple = ((name: String, age: Int?)?)")
                XCTAssertTrue(tupleType.isOptional)
            default: break
            }
            XCTAssertEqual(tupleType.arguments.count, 2)
            // String
            XCTAssertTrue(tupleType.arguments[0] is StandardParameter)
            XCTAssertEqual(tupleType.arguments[0].name, "name")
            XCTAssertNil(tupleType.arguments[0].secondName)
            XCTAssertEqual(tupleType.arguments[0].preferredName, "name")
            XCTAssertFalse(tupleType.arguments[0].isLabelOmitted)
            XCTAssertFalse(tupleType.arguments[0].variadic)
            XCTAssertFalse(tupleType.arguments[0].isOptional)
            XCTAssertFalse(tupleType.arguments[0].isInOut)
            XCTAssertEqual(tupleType.arguments[0].type, "String")
            XCTAssertEqual(tupleType.arguments[0].typeWithoutAttributes, "String")
            XCTAssertEqual(tupleType.arguments[0].description, "name: String")
            // Int
            XCTAssertTrue(tupleType.arguments[1] is StandardParameter)
            XCTAssertEqual(tupleType.arguments[1].name, "age")
            XCTAssertNil(tupleType.arguments[1].secondName)
            XCTAssertEqual(tupleType.arguments[1].preferredName, "age")
            XCTAssertFalse(tupleType.arguments[1].isLabelOmitted)
            XCTAssertFalse(tupleType.arguments[1].variadic)
            XCTAssertTrue(tupleType.arguments[1].isOptional)
            XCTAssertFalse(tupleType.arguments[1].isInOut)
            XCTAssertEqual(tupleType.arguments[1].type, "Int?")
            XCTAssertEqual(tupleType.arguments[1].typeWithoutAttributes, "Int?")
            XCTAssertEqual(tupleType.arguments[1].description, "age: Int?")
        }
    }

    func test_nestedTuple() throws {
        let source = #"""
        typealias NestedTuple = (name: String, tuple: (String, Int))
        typealias NestedTuple = (name: String, tuple: (String, Int))?
        typealias NestedTuple = (name: String, tuple: (String, Int)?)
        typealias NestedTuple = ((name: String, tuple: (String, Int)?))
        typealias NestedTuple = ((name: String, tuple: (String, Int)?))?
        """#

        let elements = try SyntaxParser.declarations(of: Typealias.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            let tupleType = try XCTUnwrap(declaration.tupleType)
            let tupleParameter = try XCTUnwrap(tupleType.arguments[1] as? TupleParameter)
            switch index {
            case 0:
                XCTAssertEqual(declaration.initializedType, "(name: String, tuple: (String, Int))")
                XCTAssertEqual(declaration.description, "typealias NestedTuple = (name: String, tuple: (String, Int))")
                XCTAssertFalse(tupleType.isOptional)
            case 1:
                XCTAssertEqual(declaration.initializedType, "(name: String, tuple: (String, Int))?")
                XCTAssertEqual(declaration.description, "typealias NestedTuple = (name: String, tuple: (String, Int))?")
                XCTAssertTrue(tupleType.isOptional)
            case 2:
                XCTAssertEqual(declaration.initializedType, "(name: String, tuple: (String, Int)?)")
                XCTAssertEqual(declaration.description, "typealias NestedTuple = (name: String, tuple: (String, Int)?)")
                XCTAssertTrue(tupleParameter.isOptional)
            case 3:
                XCTAssertEqual(declaration.initializedType, "((name: String, tuple: (String, Int)?))")
                XCTAssertEqual(declaration.description, "typealias NestedTuple = ((name: String, tuple: (String, Int)?))")
                XCTAssertTrue(tupleParameter.isOptional)
                XCTAssertFalse(tupleType.isOptional)
            case 4:
                XCTAssertEqual(declaration.initializedType, "((name: String, tuple: (String, Int)?))?")
                XCTAssertEqual(declaration.description, "typealias NestedTuple = ((name: String, tuple: (String, Int)?))?")
                XCTAssertTrue(tupleType.isOptional)
                XCTAssertTrue(tupleParameter.isOptional)
            default: break
            }
            XCTAssertEqual(tupleType.arguments.count, 2)
            // String
            XCTAssertTrue(tupleType.arguments[0] is StandardParameter)
            XCTAssertEqual(tupleType.arguments[0].name, "name")
            XCTAssertNil(tupleType.arguments[0].secondName)
            XCTAssertEqual(tupleType.arguments[0].preferredName, "name")
            XCTAssertFalse(tupleType.arguments[0].isLabelOmitted)
            XCTAssertFalse(tupleType.arguments[0].variadic)
            XCTAssertFalse(tupleType.arguments[0].isOptional)
            XCTAssertFalse(tupleType.arguments[0].isInOut)
            XCTAssertEqual(tupleType.arguments[0].type, "String")
            XCTAssertEqual(tupleType.arguments[0].typeWithoutAttributes, "String")
            XCTAssertEqual(tupleType.arguments[0].description, "name: String")
            // Tuple
            XCTAssertEqual(tupleParameter.name, "tuple")
            XCTAssertNil(tupleParameter.secondName)
            XCTAssertEqual(tupleParameter.preferredName, "tuple")
            XCTAssertFalse(tupleParameter.isLabelOmitted)
            XCTAssertFalse(tupleParameter.variadic)
            XCTAssertFalse(tupleParameter.isInOut)
            // Tuple>String
            XCTAssertTrue(tupleParameter.arguments[0] is StandardParameter)
            XCTAssertNil(tupleParameter.arguments[0].name)
            XCTAssertNil(tupleParameter.arguments[0].secondName)
            XCTAssertNil(tupleParameter.arguments[0].preferredName)
            XCTAssertFalse(tupleParameter.arguments[0].isLabelOmitted)
            XCTAssertFalse(tupleParameter.arguments[0].variadic)
            XCTAssertFalse(tupleParameter.arguments[0].isOptional)
            XCTAssertFalse(tupleParameter.arguments[0].isInOut)
            XCTAssertEqual(tupleParameter.arguments[0].type, "String")
            XCTAssertEqual(tupleParameter.arguments[0].typeWithoutAttributes, "String")
            XCTAssertEqual(tupleParameter.arguments[0].description, "String")
            // Tuple>Int
            XCTAssertNil(tupleParameter.arguments[1].name)
            XCTAssertNil(tupleParameter.arguments[1].secondName)
            XCTAssertNil(tupleParameter.arguments[1].preferredName)
            XCTAssertFalse(tupleParameter.arguments[1].isLabelOmitted)
            XCTAssertFalse(tupleParameter.arguments[1].variadic)
            XCTAssertFalse(tupleParameter.arguments[1].isInOut)
            XCTAssertEqual(tupleParameter.arguments[1].type, "Int")
            XCTAssertEqual(tupleParameter.arguments[1].typeWithoutAttributes, "Int")
            XCTAssertEqual(tupleParameter.arguments[1].description, "Int")
        }
    }

    func test_nestedTuple_withClosureArgument() throws {
        let source = #"""
        typealias NestedTuple = (name: String, tuple: (String, Int), closure: (Int) -> Void)
        typealias NestedTuple = (name: String, tuple: (String, Int), closure: (Int) -> Void)?
        typealias NestedTuple = (name: String, tuple: (String, Int)?, closure: (Int) -> Void)
        typealias NestedTuple = ((name: String, tuple: (String, Int)?, closure: (Int) -> Void))
        typealias NestedTuple = ((name: String, tuple: (String, Int)?, closure: (Int) -> Void))?
        """#

        let elements = try SyntaxParser.declarations(of: Typealias.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            let tupleType = try XCTUnwrap(declaration.tupleType, "Index: \(index)")
            let tupleParameter = try XCTUnwrap(tupleType.arguments[1] as? TupleParameter)
            switch index {
            case 0:
                XCTAssertEqual(declaration.initializedType, "(name: String, tuple: (String, Int), closure: (Int) -> Void)")
                XCTAssertEqual(declaration.description, "typealias NestedTuple = (name: String, tuple: (String, Int), closure: (Int) -> Void)")
                XCTAssertFalse(tupleType.isOptional)
            case 1:
                XCTAssertEqual(declaration.initializedType, "(name: String, tuple: (String, Int), closure: (Int) -> Void)?")
                XCTAssertEqual(declaration.description, "typealias NestedTuple = (name: String, tuple: (String, Int), closure: (Int) -> Void)?")
                XCTAssertTrue(tupleType.isOptional)
            case 2:
                XCTAssertEqual(declaration.initializedType, "(name: String, tuple: (String, Int)?, closure: (Int) -> Void)")
                XCTAssertEqual(declaration.description, "typealias NestedTuple = (name: String, tuple: (String, Int)?, closure: (Int) -> Void)")
                XCTAssertFalse(tupleType.isOptional)
                XCTAssertTrue(tupleParameter.isOptional)
            case 3:
                XCTAssertEqual(declaration.initializedType, "((name: String, tuple: (String, Int)?, closure: (Int) -> Void))")
                XCTAssertEqual(declaration.description, "typealias NestedTuple = ((name: String, tuple: (String, Int)?, closure: (Int) -> Void))")
                XCTAssertFalse(tupleType.isOptional)
                XCTAssertTrue(tupleParameter.isOptional)
            case 4:
                XCTAssertEqual(declaration.initializedType, "((name: String, tuple: (String, Int)?, closure: (Int) -> Void))?")
                XCTAssertEqual(declaration.description, "typealias NestedTuple = ((name: String, tuple: (String, Int)?, closure: (Int) -> Void))?")
                XCTAssertTrue(tupleType.isOptional)
                XCTAssertTrue(tupleParameter.isOptional)
            default: break
            }
            XCTAssertEqual(tupleType.arguments.count, 3)
            // String
            XCTAssertTrue(tupleType.arguments[0] is StandardParameter)
            XCTAssertEqual(tupleType.arguments[0].name, "name")
            XCTAssertNil(tupleType.arguments[0].secondName)
            XCTAssertEqual(tupleType.arguments[0].preferredName, "name")
            XCTAssertFalse(tupleType.arguments[0].isLabelOmitted)
            XCTAssertFalse(tupleType.arguments[0].variadic)
            XCTAssertFalse(tupleType.arguments[0].isOptional)
            XCTAssertFalse(tupleType.arguments[0].isInOut)
            XCTAssertEqual(tupleType.arguments[0].type, "String")
            XCTAssertEqual(tupleType.arguments[0].typeWithoutAttributes, "String")
            XCTAssertEqual(tupleType.arguments[0].description, "name: String")
            // Tuple
            XCTAssertEqual(tupleParameter.name, "tuple")
            XCTAssertNil(tupleParameter.secondName)
            XCTAssertEqual(tupleParameter.preferredName, "tuple")
            XCTAssertFalse(tupleParameter.isLabelOmitted)
            XCTAssertFalse(tupleParameter.variadic)
            XCTAssertFalse(tupleParameter.isInOut)
            // Tuple>String
            XCTAssertTrue(tupleParameter.arguments[0] is StandardParameter)
            XCTAssertNil(tupleParameter.arguments[0].name)
            XCTAssertNil(tupleParameter.arguments[0].secondName)
            XCTAssertNil(tupleParameter.arguments[0].preferredName)
            XCTAssertFalse(tupleParameter.arguments[0].isLabelOmitted)
            XCTAssertFalse(tupleParameter.arguments[0].variadic)
            XCTAssertFalse(tupleParameter.arguments[0].isOptional)
            XCTAssertFalse(tupleParameter.arguments[0].isInOut)
            XCTAssertEqual(tupleParameter.arguments[0].type, "String")
            XCTAssertEqual(tupleParameter.arguments[0].typeWithoutAttributes, "String")
            XCTAssertEqual(tupleParameter.arguments[0].description, "String")
            // Tuple>Int
            XCTAssertNil(tupleParameter.arguments[1].name)
            XCTAssertNil(tupleParameter.arguments[1].secondName)
            XCTAssertNil(tupleParameter.arguments[1].preferredName)
            XCTAssertFalse(tupleParameter.arguments[1].isLabelOmitted)
            XCTAssertFalse(tupleParameter.arguments[1].variadic)
            XCTAssertFalse(tupleParameter.arguments[1].isInOut)
            XCTAssertEqual(tupleParameter.arguments[1].type, "Int")
            XCTAssertEqual(tupleParameter.arguments[1].typeWithoutAttributes, "Int")
            XCTAssertEqual(tupleParameter.arguments[1].description, "Int")
            // Tuple>Closure
            XCTAssertNil(tupleType.arguments[2].name)
            XCTAssertNil(tupleType.arguments[2].secondName)
            XCTAssertNil(tupleType.arguments[2].preferredName)
            XCTAssertFalse(tupleType.arguments[2].isLabelOmitted)
            XCTAssertFalse(tupleType.arguments[2].variadic)
            XCTAssertFalse(tupleType.arguments[2].isInOut)
            let closureArgument = try XCTUnwrap(tupleType.arguments[2] as? ClosureParameter)
            XCTAssertEqual(closureArgument.inputs.count, 1)
            XCTAssertFalse(closureArgument.isVoidInput)
            XCTAssertEqual(closureArgument.inputType, "Int")
            XCTAssertEqual(closureArgument.rawInput, "(Int)")
            XCTAssertTrue(closureArgument.isVoidOutput)
            XCTAssertEqual(closureArgument.outputType, "Void")
            XCTAssertEqual(closureArgument.rawOutput, "Void")
            XCTAssertNil(closureArgument.inputs[0].name)
            XCTAssertNil(closureArgument.inputs[0].secondName)
            XCTAssertNil(closureArgument.inputs[0].preferredName)
            XCTAssertFalse(closureArgument.inputs[0].isLabelOmitted)
            XCTAssertFalse(closureArgument.inputs[0].variadic)
            XCTAssertFalse(closureArgument.inputs[0].isInOut)
            XCTAssertEqual(closureArgument.inputs[0].type, "Int")
            XCTAssertEqual(closureArgument.inputs[0].typeWithoutAttributes, "Int")
            XCTAssertEqual(closureArgument.inputs[0].description, "Int")
        }
    }
}
