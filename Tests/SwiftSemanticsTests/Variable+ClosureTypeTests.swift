@testable import SwiftSemantics
import SwiftSemantics
import SwiftSyntax
import SwiftSyntaxParser
import XCTest

final class VariableClosureTypeTests: XCTestCase {

    // MARK: - Tests: Closures: Void Inputs

    func test_closureVoidInput_literalVoid() throws {
        let source = #"""
        let voidInput: (Void -> ())
        let voidInput: (Void -> ())?
        let voidInput: ((Void) -> ())
        let voidInput: ((Void) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "(Void -> ())")
                XCTAssertEqual(declaration.description, "let voidInput: (Void -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(Void -> ())?")
                XCTAssertEqual(declaration.description, "let voidInput: (Void -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((Void) -> ())")
                XCTAssertEqual(declaration.description, "let voidInput: ((Void) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 3:
                XCTAssertEqual(declaration.typeAnnotation, "((Void) -> ())?")
                XCTAssertEqual(declaration.description, "let voidInput: ((Void) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertTrue(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertEqual(closureType.inputs.count, 0)
            // Outputs have dedicated tests
        }
    }

    func test_closureVoidInput_resultInput() throws {
        let source = #"""
        let resultInput: ((Result<String, Error>, Int) -> ())
        let resultInput: ((Result<String, Error>?, Int) -> ())?
        let resultInput: ((Result<String?, Error>?, Int, String) -> ())
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "((Result<String, Error>, Int) -> ())")
                XCTAssertEqual(declaration.description, "let resultInput: ((Result<String, Error>, Int) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.inputType, "(Result<String, Error>, Int)")
                XCTAssertEqual(closureType.inputs[0].type, "Result<String, Error>")
                XCTAssertFalse(closureType.inputs[0].isOptional)
                XCTAssertEqual(closureType.inputs[1].type, "Int")
                XCTAssertEqual(closureType.inputs.count, 2)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "((Result<String, Error>?, Int) -> ())?")
                XCTAssertEqual(declaration.description, "let resultInput: ((Result<String, Error>?, Int) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.inputType, "(Result<String, Error>?, Int)")
                XCTAssertEqual(closureType.inputs[0].type, "Result<String, Error>?")
                XCTAssertTrue(closureType.inputs[0].isOptional)
                XCTAssertEqual(closureType.inputs[1].type, "Int")
                XCTAssertEqual(closureType.inputs.count, 2)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((Result<String?, Error>?, Int, String) -> ())")
                XCTAssertEqual(declaration.description, "let resultInput: ((Result<String?, Error>?, Int, String) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.inputType, "(Result<String?, Error>?, Int, String)")
                XCTAssertEqual(closureType.inputs[0].type, "Result<String?, Error>?")
                XCTAssertTrue(closureType.inputs[0].isOptional)
                XCTAssertEqual(closureType.inputs[1].type, "Int")
                XCTAssertEqual(closureType.inputs[2].type, "String")
                XCTAssertEqual(closureType.inputs.count, 3)
            default: break
            }
        }
    }

    func test_closureVoidInput_resultOutput() throws {
        let source = #"""
        let resultInput: (() -> Result<String, Error>)
        let resultInput: (() -> (Result<String, Error>?, Int))?
        let resultInput: (() -> (Result<String, Error>, Int?, String))
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> Result<String, Error>)")
                XCTAssertEqual(declaration.description, "let resultInput: (() -> Result<String, Error>)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.outputType, "Result<String, Error>")
                XCTAssertEqual(closureType.outputs[0].type, "Result<String, Error>")
                XCTAssertFalse(closureType.outputs[0].isOptional)
                XCTAssertEqual(closureType.outputs.count, 1)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (Result<String, Error>?, Int))?")
                XCTAssertEqual(declaration.description, "let resultInput: (() -> (Result<String, Error>?, Int))?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.outputType, "(Result<String, Error>?, Int)")
                XCTAssertEqual(closureType.outputs[0].type, "Result<String, Error>?")
                XCTAssertTrue(closureType.outputs[0].isOptional)
                XCTAssertEqual(closureType.outputs[1].type, "Int")
                XCTAssertFalse(closureType.outputs[1].isOptional)
                XCTAssertEqual(closureType.outputs.count, 2)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (Result<String, Error>, Int?, String))")
                XCTAssertEqual(declaration.description, "let resultInput: (() -> (Result<String, Error>, Int?, String))")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.outputType, "(Result<String, Error>, Int?, String)")
                XCTAssertEqual(closureType.outputs[0].type, "Result<String, Error>")
                XCTAssertFalse(closureType.outputs[0].isOptional)
                XCTAssertEqual(closureType.outputs[1].type, "Int?")
                XCTAssertTrue(closureType.outputs[1].isOptional)
                XCTAssertEqual(closureType.outputs[2].type, "String")
                XCTAssertFalse(closureType.outputs[2].isOptional)
                XCTAssertEqual(closureType.outputs.count, 3)
            default: break
            }
        }
    }

    func test_closureVoidInput_standard() throws {
        let source = #"""
        let voidInput: () -> ()
        let voidInput: (()) -> ()
        let voidInput: ((()) -> ())
        let voidInput: ((()) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType, "Index: \(index)")
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "() -> ()")
                XCTAssertEqual(declaration.description, "let voidInput: () -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(()) -> ()")
                XCTAssertEqual(declaration.description, "let voidInput: (()) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((()) -> ())")
                XCTAssertEqual(declaration.description, "let voidInput: ((()) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 3:
                XCTAssertEqual(declaration.typeAnnotation, "((()) -> ())?")
                XCTAssertEqual(declaration.description, "let voidInput: ((()) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertTrue(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertEqual(closureType.inputs.count, 0)
            // Outputs have dedicated tests
        }
    }

    // MARK: - Tests: Closures: Single Primitive Input

    func test_singlePrimitiveInput_nameless() throws {
        let source = #"""
        let primitiveInput: (String) -> ()
        let primitiveInput: ((String) -> ())
        let primitiveInput: ((String) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "(String) -> ()")
                XCTAssertEqual(declaration.description, "let primitiveInput: (String) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "((String) -> ())")
                XCTAssertEqual(declaration.description, "let primitiveInput: ((String) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((String) -> ())?")
                XCTAssertEqual(declaration.description, "let primitiveInput: ((String) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertFalse(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertFalse(closureType.isEscaping)
            XCTAssertEqual(closureType.inputs.count, 1)
            XCTAssertTrue(closureType.inputs[0] is StandardParameter)
            XCTAssertNil(closureType.inputs[0].name)
            XCTAssertNil(closureType.inputs[0].secondName)
            XCTAssertNil(closureType.inputs[0].preferredName)
            XCTAssertFalse(closureType.inputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[0].type, "String")
            XCTAssertEqual(closureType.inputs[0].typeWithoutAttributes, "String")
            XCTAssertFalse(closureType.inputs[0].isOptional)
            XCTAssertFalse(closureType.inputs[0].variadic)
            XCTAssertFalse(closureType.inputs[0].isInOut)
            XCTAssertEqual(closureType.inputs[0].description, "String")
            // Outputs have dedicated tests
        }
    }

    func test_primitiveInput_optional_nameless() throws {
        let source = #"""
        let primitiveInput: (String?) -> ()
        let primitiveInput: ((String?) -> ())
        let primitiveInput: ((String?) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "(String?) -> ()")
                XCTAssertEqual(declaration.description, "let primitiveInput: (String?) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "((String?) -> ())")
                XCTAssertEqual(declaration.description, "let primitiveInput: ((String?) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((String?) -> ())?")
                XCTAssertEqual(declaration.description, "let primitiveInput: ((String?) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertFalse(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertFalse(closureType.isEscaping)
            XCTAssertEqual(closureType.inputs.count, 1)
            XCTAssertTrue(closureType.inputs[0] is StandardParameter)
            XCTAssertNil(closureType.inputs[0].name)
            XCTAssertNil(closureType.inputs[0].secondName)
            XCTAssertNil(closureType.inputs[0].preferredName)
            XCTAssertFalse(closureType.inputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[0].type, "String?")
            XCTAssertEqual(closureType.inputs[0].typeWithoutAttributes, "String?")
            XCTAssertTrue(closureType.inputs[0].isOptional)
            XCTAssertFalse(closureType.inputs[0].variadic)
            XCTAssertFalse(closureType.inputs[0].isInOut)
            XCTAssertEqual(closureType.inputs[0].description, "String?")
            // Outputs have dedicated tests
        }
    }

    func test_singlePrimitiveInput_named_labelOmitted_wrapped_optionalClosure() throws {
        let source = #"""
        let primitiveInput: (_ name: String) -> ()
        let primitiveInput: ((_ name: String) -> ())
        let primitiveInput: ((_ name: String) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "(_ name: String) -> ()")
                XCTAssertEqual(declaration.description, "let primitiveInput: (_ name: String) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "((_ name: String) -> ())")
                XCTAssertEqual(declaration.description, "let primitiveInput: ((_ name: String) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((_ name: String) -> ())?")
                XCTAssertEqual(declaration.description, "let primitiveInput: ((_ name: String) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertFalse(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertFalse(closureType.isEscaping)
            XCTAssertEqual(closureType.inputs.count, 1)
            XCTAssertTrue(closureType.inputs[0] is StandardParameter)
            XCTAssertEqual(closureType.inputs[0].name, "_")
            XCTAssertEqual(closureType.inputs[0].secondName, "name")
            XCTAssertEqual(closureType.inputs[0].preferredName, "name")
            XCTAssertTrue(closureType.inputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[0].type, "String")
            XCTAssertEqual(closureType.inputs[0].typeWithoutAttributes, "String")
            XCTAssertFalse(closureType.inputs[0].isOptional)
            XCTAssertFalse(closureType.inputs[0].variadic)
            XCTAssertFalse(closureType.inputs[0].isInOut)
            XCTAssertEqual(closureType.inputs[0].description, "_ name: String")
            // Outputs have dedicated tests
        }
    }

    // MARK: - Tests: Closures: Multiple Primitive Inputs

    func test_multiplePrimitiveInput() throws {
        let source = #"""
        let primitiveInput: (String?, Int) -> ()
        let primitiveInput: ((String?, Int) -> ())
        let primitiveInput: ((String?, Int) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "(String?, Int) -> ()")
                XCTAssertEqual(declaration.description, "let primitiveInput: (String?, Int) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "((String?, Int) -> ())")
                XCTAssertEqual(declaration.description, "let primitiveInput: ((String?, Int) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((String?, Int) -> ())?")
                XCTAssertEqual(declaration.description, "let primitiveInput: ((String?, Int) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertFalse(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertFalse(closureType.isEscaping)
            XCTAssertEqual(closureType.inputs.count, 2)
            XCTAssertTrue(closureType.inputs[0] is StandardParameter)
            XCTAssertNil(closureType.inputs[0].name)
            XCTAssertNil(closureType.inputs[0].secondName)
            XCTAssertNil(closureType.inputs[0].preferredName)
            XCTAssertFalse(closureType.inputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[0].type, "String?")
            XCTAssertEqual(closureType.inputs[0].typeWithoutAttributes, "String?")
            XCTAssertTrue(closureType.inputs[0].isOptional)
            XCTAssertFalse(closureType.inputs[0].variadic)
            XCTAssertFalse(closureType.inputs[0].isInOut)
            XCTAssertEqual(closureType.inputs[0].description, "String?")
            XCTAssertTrue(closureType.inputs[1] is StandardParameter)
            XCTAssertNil(closureType.inputs[1].name)
            XCTAssertNil(closureType.inputs[1].secondName)
            XCTAssertNil(closureType.inputs[1].preferredName)
            XCTAssertFalse(closureType.inputs[1].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[1].type, "Int")
            XCTAssertEqual(closureType.inputs[1].typeWithoutAttributes, "Int")
            XCTAssertFalse(closureType.inputs[1].isOptional)
            XCTAssertFalse(closureType.inputs[1].variadic)
            XCTAssertFalse(closureType.inputs[1].isInOut)
            XCTAssertEqual(closureType.inputs[1].description, "Int")
            // Outputs have dedicated tests
        }
    }

    func test_multiplePrimitiveInput_named_labelOmitted_optionalClosure() throws {
        let source = #"""
        let primitiveInput: (_ name: String?, _ age: Int) -> ()
        let primitiveInput: ((_ name: String?, _ age: Int) -> ())
        let primitiveInput: ((_ name: String?, _ age: Int) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "(_ name: String?, _ age: Int) -> ()")
                XCTAssertEqual(declaration.description, "let primitiveInput: (_ name: String?, _ age: Int) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "((_ name: String?, _ age: Int) -> ())")
                XCTAssertEqual(declaration.description, "let primitiveInput: ((_ name: String?, _ age: Int) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((_ name: String?, _ age: Int) -> ())?")
                XCTAssertEqual(declaration.description, "let primitiveInput: ((_ name: String?, _ age: Int) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertFalse(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertFalse(closureType.isEscaping)
            XCTAssertEqual(closureType.inputs.count, 2)
            XCTAssertTrue(closureType.inputs[0] is StandardParameter)
            XCTAssertEqual(closureType.inputs[0].name, "_")
            XCTAssertEqual(closureType.inputs[0].secondName, "name")
            XCTAssertEqual(closureType.inputs[0].preferredName, "name")
            XCTAssertTrue(closureType.inputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[0].type, "String?")
            XCTAssertEqual(closureType.inputs[0].typeWithoutAttributes, "String?")
            XCTAssertTrue(closureType.inputs[0].isOptional)
            XCTAssertFalse(closureType.inputs[0].variadic)
            XCTAssertFalse(closureType.inputs[0].isInOut)
            XCTAssertEqual(closureType.inputs[0].description, "_ name: String?")
            XCTAssertTrue(closureType.inputs[1] is StandardParameter)
            XCTAssertEqual(closureType.inputs[1].name, "_")
            XCTAssertEqual(closureType.inputs[1].secondName, "age")
            XCTAssertEqual(closureType.inputs[1].preferredName, "age")
            XCTAssertTrue(closureType.inputs[1].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[1].type, "Int")
            XCTAssertEqual(closureType.inputs[1].typeWithoutAttributes, "Int")
            XCTAssertFalse(closureType.inputs[1].isOptional)
            XCTAssertFalse(closureType.inputs[1].variadic)
            XCTAssertFalse(closureType.inputs[1].isInOut)
            XCTAssertEqual(closureType.inputs[1].description, "_ age: Int")
            // Outputs have dedicated tests
        }
    }

    // MARK: - Tests: Closures: Tuple Inputs

    func test_tupleInput_nameless_optionalClosure() throws {
        let source = #"""
        let tupleInput: ((String, Int?)) -> ()
        let tupleInput: (((String, Int?)) -> ())
        let tupleInput: (((String, Int?)) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "((String, Int?)) -> ()")
                XCTAssertEqual(declaration.description, "let tupleInput: ((String, Int?)) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(((String, Int?)) -> ())")
                XCTAssertEqual(declaration.description, "let tupleInput: (((String, Int?)) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "(((String, Int?)) -> ())?")
                XCTAssertEqual(declaration.description, "let tupleInput: (((String, Int?)) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertFalse(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertFalse(closureType.isEscaping)
            XCTAssertEqual(closureType.inputs.count, 1)
            XCTAssertTrue(closureType.inputs[0] is TupleParameter)
            XCTAssertNil(closureType.inputs[0].name)
            XCTAssertNil(closureType.inputs[0].secondName)
            XCTAssertNil(closureType.inputs[0].preferredName)
            XCTAssertFalse(closureType.inputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[0].type, "(String, Int?)")
            XCTAssertEqual(closureType.inputs[0].typeWithoutAttributes, "(String, Int?)")
            XCTAssertFalse(closureType.inputs[0].isOptional)
            XCTAssertFalse(closureType.inputs[0].variadic)
            XCTAssertFalse(closureType.inputs[0].isInOut)
            XCTAssertEqual(closureType.inputs[0].description, "(String, Int?)")
            let tuple = try XCTUnwrap(closureType.inputs[0] as? TupleParameter)
            XCTAssertEqual(tuple.arguments.count, 2)
            XCTAssertTrue(tuple.arguments[0] is StandardParameter)
            XCTAssertNil(tuple.arguments[0].name)
            XCTAssertNil(tuple.arguments[0].secondName)
            XCTAssertNil(closureType.inputs[0].preferredName)
            XCTAssertFalse(tuple.arguments[0].isLabelOmitted)
            XCTAssertEqual(tuple.arguments[0].type, "String")
            XCTAssertEqual(tuple.arguments[0].typeWithoutAttributes, "String")
            XCTAssertFalse(tuple.arguments[0].isOptional)
            XCTAssertFalse(tuple.arguments[0].variadic)
            XCTAssertFalse(tuple.arguments[0].isInOut)
            XCTAssertEqual(tuple.arguments[0].description, "String")
            XCTAssertTrue(tuple.arguments[1] is StandardParameter)
            XCTAssertNil(tuple.arguments[1].name)
            XCTAssertNil(tuple.arguments[1].secondName)
            XCTAssertNil(tuple.arguments[1].preferredName)
            XCTAssertFalse(tuple.arguments[1].isLabelOmitted)
            XCTAssertEqual(tuple.arguments[1].type, "Int?")
            XCTAssertEqual(tuple.arguments[1].typeWithoutAttributes, "Int?")
            XCTAssertTrue(tuple.arguments[1].isOptional)
            XCTAssertFalse(tuple.arguments[1].variadic)
            XCTAssertFalse(tuple.arguments[1].isInOut)
            XCTAssertEqual(tuple.arguments[1].description, "Int?")
            // Outputs have dedicated tests
        }
    }

    func test_tupleInput_named_optionalClosure() throws {
        let source = #"""
        let tupleInput: ((name: String, age: Int?)) -> ()
        let tupleInput: (((name: String, age: Int?)) -> ())
        let tupleInput: (((name: String, age: Int?)) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "((name: String, age: Int?)) -> ()")
                XCTAssertEqual(declaration.description, "let tupleInput: ((name: String, age: Int?)) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(((name: String, age: Int?)) -> ())")
                XCTAssertEqual(declaration.description, "let tupleInput: (((name: String, age: Int?)) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "(((name: String, age: Int?)) -> ())?")
                XCTAssertEqual(declaration.description, "let tupleInput: (((name: String, age: Int?)) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertFalse(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertFalse(closureType.isEscaping)
            XCTAssertEqual(closureType.inputs.count, 1)
            XCTAssertTrue(closureType.inputs[0] is TupleParameter)
            XCTAssertNil(closureType.inputs[0].name)
            XCTAssertNil(closureType.inputs[0].secondName)
            XCTAssertNil(closureType.inputs[0].preferredName)
            XCTAssertFalse(closureType.inputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[0].type, "(name: String, age: Int?)")
            XCTAssertEqual(closureType.inputs[0].typeWithoutAttributes, "(name: String, age: Int?)")
            XCTAssertFalse(closureType.inputs[0].isOptional)
            XCTAssertFalse(closureType.inputs[0].variadic)
            XCTAssertFalse(closureType.inputs[0].isInOut)
            XCTAssertEqual(closureType.inputs[0].description, "(name: String, age: Int?)")
            let tuple = try XCTUnwrap(closureType.inputs[0] as? TupleParameter)
            XCTAssertEqual(tuple.arguments.count, 2)
            XCTAssertTrue(tuple.arguments[0] is StandardParameter)
            XCTAssertEqual(tuple.arguments[0].name, "name")
            XCTAssertNil(tuple.arguments[0].secondName)
            XCTAssertEqual(tuple.arguments[0].preferredName, "name")
            XCTAssertFalse(tuple.arguments[0].isLabelOmitted)
            XCTAssertEqual(tuple.arguments[0].type, "String")
            XCTAssertEqual(tuple.arguments[0].typeWithoutAttributes, "String")
            XCTAssertFalse(tuple.arguments[0].isOptional)
            XCTAssertFalse(tuple.arguments[0].variadic)
            XCTAssertFalse(tuple.arguments[0].isInOut)
            XCTAssertEqual(tuple.arguments[0].description, "name: String")
            XCTAssertTrue(tuple.arguments[1] is StandardParameter)
            XCTAssertEqual(tuple.arguments[1].name, "age")
            XCTAssertNil(tuple.arguments[1].secondName)
            XCTAssertEqual(tuple.arguments[1].preferredName, "age")
            XCTAssertFalse(tuple.arguments[1].isLabelOmitted)
            XCTAssertEqual(tuple.arguments[1].type, "Int?")
            XCTAssertEqual(tuple.arguments[1].typeWithoutAttributes, "Int?")
            XCTAssertTrue(tuple.arguments[1].isOptional)
            XCTAssertFalse(tuple.arguments[1].variadic)
            XCTAssertFalse(tuple.arguments[1].isInOut)
            XCTAssertEqual(tuple.arguments[1].description, "age: Int?")
            // Outputs have dedicated tests
        }
    }

    func test_mixedInput_nameless_optionalClosure() throws {
        let source = #"""
        let mixedInput: (String, Int, (name: String, age: Int)) -> ()
        let mixedInput: ((String, Int, (name: String, age: Int)) -> ())
        let mixedInput: ((String, Int, (name: String, age: Int)) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "(String, Int, (name: String, age: Int)) -> ()")
                XCTAssertEqual(declaration.description, "let mixedInput: (String, Int, (name: String, age: Int)) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "((String, Int, (name: String, age: Int)) -> ())")
                XCTAssertEqual(declaration.description, "let mixedInput: ((String, Int, (name: String, age: Int)) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((String, Int, (name: String, age: Int)) -> ())?")
                XCTAssertEqual(declaration.description, "let mixedInput: ((String, Int, (name: String, age: Int)) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertFalse(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertFalse(closureType.isEscaping)
            XCTAssertEqual(closureType.inputs.count, 3)
            XCTAssertTrue(closureType.inputs[0] is StandardParameter)
            XCTAssertNil(closureType.inputs[0].name)
            XCTAssertNil(closureType.inputs[0].secondName)
            XCTAssertNil(closureType.inputs[0].preferredName)
            XCTAssertFalse(closureType.inputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[0].type, "String")
            XCTAssertEqual(closureType.inputs[0].typeWithoutAttributes, "String")
            XCTAssertFalse(closureType.inputs[0].isOptional)
            XCTAssertFalse(closureType.inputs[0].variadic)
            XCTAssertFalse(closureType.inputs[0].isInOut)
            XCTAssertEqual(closureType.inputs[0].description, "String")
            XCTAssertTrue(closureType.inputs[1] is StandardParameter)
            XCTAssertNil(closureType.inputs[1].name)
            XCTAssertNil(closureType.inputs[1].secondName)
            XCTAssertNil(closureType.inputs[1].preferredName)
            XCTAssertFalse(closureType.inputs[1].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[1].type, "Int")
            XCTAssertEqual(closureType.inputs[1].typeWithoutAttributes, "Int")
            XCTAssertFalse(closureType.inputs[1].isOptional)
            XCTAssertFalse(closureType.inputs[1].variadic)
            XCTAssertFalse(closureType.inputs[1].isInOut)
            XCTAssertEqual(closureType.inputs[1].description, "Int")
            let tuple = try XCTUnwrap(closureType.inputs[2] as? TupleParameter)
            XCTAssertFalse(tuple.isLabelOmitted)
            XCTAssertFalse(tuple.isOptional)
            XCTAssertNil(tuple.name)
            XCTAssertNil(tuple.preferredName)
            XCTAssertFalse(tuple.variadic)
            XCTAssertFalse(tuple.isInOut)
            XCTAssertEqual(tuple.type, "(name: String, age: Int)")
            XCTAssertEqual(tuple.typeWithoutAttributes, "(name: String, age: Int)")
            XCTAssertEqual(tuple.description, "(name: String, age: Int)")
            XCTAssertEqual(tuple.arguments.count, 2)
            XCTAssertTrue(tuple.arguments[0] is StandardParameter)
            XCTAssertEqual(tuple.arguments[0].name, "name")
            XCTAssertNil(tuple.arguments[0].secondName)
            XCTAssertEqual(tuple.arguments[0].preferredName, "name")
            XCTAssertFalse(tuple.arguments[0].isLabelOmitted)
            XCTAssertEqual(tuple.arguments[0].type, "String")
            XCTAssertEqual(tuple.arguments[0].typeWithoutAttributes, "String")
            XCTAssertFalse(tuple.arguments[0].isOptional)
            XCTAssertFalse(tuple.arguments[0].variadic)
            XCTAssertFalse(tuple.arguments[0].isInOut)
            XCTAssertEqual(tuple.arguments[0].description, "name: String")
            XCTAssertTrue(tuple.arguments[1] is StandardParameter)
            XCTAssertEqual(tuple.arguments[1].name, "age")
            XCTAssertNil(tuple.arguments[1].secondName)
            XCTAssertEqual(tuple.arguments[1].preferredName, "age")
            XCTAssertFalse(tuple.arguments[1].isLabelOmitted)
            XCTAssertEqual(tuple.arguments[1].type, "Int")
            XCTAssertEqual(tuple.arguments[1].typeWithoutAttributes, "Int")
            XCTAssertFalse(tuple.arguments[1].isOptional)
            XCTAssertFalse(tuple.arguments[1].variadic)
            XCTAssertFalse(tuple.arguments[1].isInOut)
            XCTAssertEqual(tuple.arguments[1].description, "age: Int")
            // Outputs have dedicated tests
        }
    }

    func test_mixedInput_namedTuple() throws {
        let source = #"""
        let mixedInput: (String, Int, tuple: (name: String, age: Int)) -> ()
        let mixedInput: ((String, Int, tuple: (name: String, age: Int)) -> ())
        let mixedInput: ((String, Int, tuple: (name: String, age: Int)) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "(String, Int, tuple: (name: String, age: Int)) -> ()")
                XCTAssertEqual(declaration.description, "let mixedInput: (String, Int, tuple: (name: String, age: Int)) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "((String, Int, tuple: (name: String, age: Int)) -> ())")
                XCTAssertEqual(declaration.description, "let mixedInput: ((String, Int, tuple: (name: String, age: Int)) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((String, Int, tuple: (name: String, age: Int)) -> ())?")
                XCTAssertEqual(declaration.description, "let mixedInput: ((String, Int, tuple: (name: String, age: Int)) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertFalse(closureType.isEscaping)
            XCTAssertFalse(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertEqual(closureType.inputs.count, 3)
            XCTAssertTrue(closureType.inputs[0] is StandardParameter)
            XCTAssertNil(closureType.inputs[0].name)
            XCTAssertNil(closureType.inputs[0].secondName)
            XCTAssertNil(closureType.inputs[0].preferredName)
            XCTAssertFalse(closureType.inputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[0].type, "String")
            XCTAssertEqual(closureType.inputs[0].typeWithoutAttributes, "String")
            XCTAssertFalse(closureType.inputs[0].isOptional)
            XCTAssertFalse(closureType.inputs[0].variadic)
            XCTAssertFalse(closureType.inputs[0].isInOut)
            XCTAssertEqual(closureType.inputs[0].description, "String")
            XCTAssertTrue(closureType.inputs[1] is StandardParameter)
            XCTAssertNil(closureType.inputs[1].name)
            XCTAssertNil(closureType.inputs[1].secondName)
            XCTAssertNil(closureType.inputs[1].preferredName)
            XCTAssertFalse(closureType.inputs[1].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[1].type, "Int")
            XCTAssertEqual(closureType.inputs[1].typeWithoutAttributes, "Int")
            XCTAssertFalse(closureType.inputs[1].isOptional)
            XCTAssertFalse(closureType.inputs[1].variadic)
            XCTAssertFalse(closureType.inputs[1].isInOut)
            XCTAssertEqual(closureType.inputs[1].description, "Int")
            let tuple = try XCTUnwrap(closureType.inputs[2] as? TupleParameter)
            XCTAssertFalse(tuple.isLabelOmitted)
            XCTAssertFalse(tuple.isOptional)
            XCTAssertEqual(tuple.name, "tuple")
            XCTAssertEqual(tuple.preferredName, "tuple")
            XCTAssertFalse(tuple.variadic)
            XCTAssertFalse(tuple.isInOut)
            XCTAssertEqual(tuple.type, "(name: String, age: Int)")
            XCTAssertEqual(tuple.typeWithoutAttributes, "(name: String, age: Int)")
            XCTAssertEqual(tuple.description, "tuple: (name: String, age: Int)")
            XCTAssertEqual(tuple.arguments.count, 2)
            XCTAssertTrue(tuple.arguments[0] is StandardParameter)
            XCTAssertEqual(tuple.arguments[0].name, "name")
            XCTAssertNil(tuple.arguments[0].secondName)
            XCTAssertEqual(tuple.arguments[0].preferredName, "name")
            XCTAssertFalse(tuple.arguments[0].isLabelOmitted)
            XCTAssertEqual(tuple.arguments[0].type, "String")
            XCTAssertEqual(tuple.arguments[0].typeWithoutAttributes, "String")
            XCTAssertFalse(tuple.arguments[0].isOptional)
            XCTAssertFalse(tuple.arguments[0].variadic)
            XCTAssertFalse(tuple.arguments[0].isInOut)
            XCTAssertEqual(tuple.arguments[0].description, "name: String")
            XCTAssertTrue(tuple.arguments[1] is StandardParameter)
            XCTAssertEqual(tuple.arguments[1].name, "age")
            XCTAssertNil(tuple.arguments[1].secondName)
            XCTAssertEqual(tuple.arguments[1].preferredName, "age")
            XCTAssertFalse(tuple.arguments[1].isLabelOmitted)
            XCTAssertEqual(tuple.arguments[1].type, "Int")
            XCTAssertEqual(tuple.arguments[1].typeWithoutAttributes, "Int")
            XCTAssertFalse(tuple.arguments[1].isOptional)
            XCTAssertFalse(tuple.arguments[1].variadic)
            XCTAssertFalse(tuple.arguments[1].isInOut)
            XCTAssertEqual(tuple.arguments[1].description, "age: Int")
        }
    }

    func test_mixedInput_labelessTuple() throws {
        let source = #"""
        let mixedInput: (String, Int, _: (name: String, age: Int)) -> ()
        let mixedInput: ((String, Int, _: (name: String, age: Int)) -> ())
        let mixedInput: ((String, Int, _: (name: String, age: Int)) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "(String, Int, _: (name: String, age: Int)) -> ()")
                XCTAssertEqual(declaration.description, "let mixedInput: (String, Int, _: (name: String, age: Int)) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "((String, Int, _: (name: String, age: Int)) -> ())")
                XCTAssertEqual(declaration.description, "let mixedInput: ((String, Int, _: (name: String, age: Int)) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((String, Int, _: (name: String, age: Int)) -> ())?")
                XCTAssertEqual(declaration.description, "let mixedInput: ((String, Int, _: (name: String, age: Int)) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertFalse(closureType.isEscaping)
            XCTAssertFalse(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertEqual(closureType.inputs.count, 3)
            XCTAssertTrue(closureType.inputs[0] is StandardParameter)
            XCTAssertNil(closureType.inputs[0].name)
            XCTAssertNil(closureType.inputs[0].secondName)
            XCTAssertNil(closureType.inputs[0].preferredName)
            XCTAssertFalse(closureType.inputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[0].type, "String")
            XCTAssertEqual(closureType.inputs[0].typeWithoutAttributes, "String")
            XCTAssertFalse(closureType.inputs[0].isOptional)
            XCTAssertFalse(closureType.inputs[0].variadic)
            XCTAssertFalse(closureType.inputs[0].isInOut)
            XCTAssertEqual(closureType.inputs[0].description, "String")
            XCTAssertTrue(closureType.inputs[1] is StandardParameter)
            XCTAssertNil(closureType.inputs[1].name)
            XCTAssertNil(closureType.inputs[1].secondName)
            XCTAssertNil(closureType.inputs[1].preferredName)
            XCTAssertFalse(closureType.inputs[1].isLabelOmitted)
            XCTAssertEqual(closureType.inputs[1].type, "Int")
            XCTAssertEqual(closureType.inputs[1].typeWithoutAttributes, "Int")
            XCTAssertFalse(closureType.inputs[1].isOptional)
            XCTAssertFalse(closureType.inputs[1].variadic)
            XCTAssertFalse(closureType.inputs[1].isInOut)
            XCTAssertEqual(closureType.inputs[1].description, "Int")
            let tuple = try XCTUnwrap(closureType.inputs[2] as? TupleParameter)
            XCTAssertTrue(tuple.isLabelOmitted)
            XCTAssertFalse(tuple.isOptional)
            XCTAssertEqual(tuple.name, "_")
            XCTAssertNil(tuple.preferredName)
            XCTAssertFalse(tuple.variadic)
            XCTAssertFalse(tuple.isInOut)
            XCTAssertEqual(tuple.type, "(name: String, age: Int)")
            XCTAssertEqual(tuple.typeWithoutAttributes, "(name: String, age: Int)")
            XCTAssertEqual(tuple.description, "_: (name: String, age: Int)")
            XCTAssertEqual(tuple.arguments.count, 2)
            XCTAssertTrue(tuple.arguments[0] is StandardParameter)
            XCTAssertEqual(tuple.arguments[0].name, "name")
            XCTAssertNil(tuple.arguments[0].secondName)
            XCTAssertEqual(tuple.arguments[0].preferredName, "name")
            XCTAssertFalse(tuple.arguments[0].isLabelOmitted)
            XCTAssertEqual(tuple.arguments[0].type, "String")
            XCTAssertEqual(tuple.arguments[0].typeWithoutAttributes, "String")
            XCTAssertFalse(tuple.arguments[0].isOptional)
            XCTAssertFalse(tuple.arguments[0].variadic)
            XCTAssertFalse(tuple.arguments[0].isInOut)
            XCTAssertEqual(tuple.arguments[0].description, "name: String")
            XCTAssertTrue(tuple.arguments[1] is StandardParameter)
            XCTAssertEqual(tuple.arguments[1].name, "age")
            XCTAssertNil(tuple.arguments[1].secondName)
            XCTAssertEqual(tuple.arguments[1].preferredName, "age")
            XCTAssertFalse(tuple.arguments[1].isLabelOmitted)
            XCTAssertEqual(tuple.arguments[1].type, "Int")
            XCTAssertEqual(tuple.arguments[1].typeWithoutAttributes, "Int")
            XCTAssertFalse(tuple.arguments[1].isOptional)
            XCTAssertFalse(tuple.arguments[1].variadic)
            XCTAssertFalse(tuple.arguments[1].isInOut)
            XCTAssertEqual(tuple.arguments[1].description, "age: Int")
        }
    }

    // MARK: - Tests: Closures: Void Outputs
    func test_closureVoidOutput_literalVoid() throws {
        let source = #"""
        let voidOutput: (() -> Void)
        let voidOutput: (() -> Void)?
        let voidOutput: (() -> (Void))
        let voidOutput: (() -> (Void))?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> Void)")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> Void)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> Void)?")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> Void)?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (Void))")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> (Void))")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 3:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (Void))?")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> (Void))?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertTrue(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertEqual(closureType.outputs.count, 0)
            // Inputs have dedicated tests
        }
    }

    func test_closureVoidOutput_standard() throws {
        let source = #"""
        let voidOutput: () -> ()
        let voidOutput: (()) -> ()
        let voidOutput: ((()) -> ())
        let voidOutput: ((()) -> ())?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "() -> ()")
                XCTAssertEqual(declaration.description, "let voidOutput: () -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(()) -> ()")
                XCTAssertEqual(declaration.description, "let voidOutput: (()) -> ()")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "((()) -> ())")
                XCTAssertEqual(declaration.description, "let voidOutput: ((()) -> ())")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 3:
                XCTAssertEqual(declaration.typeAnnotation, "((()) -> ())?")
                XCTAssertEqual(declaration.description, "let voidOutput: ((()) -> ())?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertTrue(closureType.isVoidInput)
            XCTAssertTrue(closureType.isVoidOutput)
            XCTAssertEqual(closureType.outputs.count, 0)
            // Outputs have dedicated tests
        }
    }

    func test_singlePrimitiveOutput() throws {
        let source = #"""
        let voidOutput: () -> String
        let voidOutput: (() -> String)
        let voidOutput: (() -> String)?
        let voidOutput: () -> (String)
        let voidOutput: (() -> (String))
        let voidOutput: (() -> (String))?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "() -> String")
                XCTAssertEqual(declaration.description, "let voidOutput: () -> String")
                XCTAssertEqual(closureType.outputType, "String")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> String)")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> String)")
                XCTAssertEqual(closureType.outputType, "String")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> String)?")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> String)?")
                XCTAssertEqual(closureType.outputType, "String")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            case 3:
                XCTAssertEqual(declaration.typeAnnotation, "() -> (String)")
                XCTAssertEqual(declaration.description, "let voidOutput: () -> (String)")
                XCTAssertEqual(closureType.outputType, "(String)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 4:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (String))")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> (String))")
                XCTAssertEqual(closureType.outputType, "(String)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 5:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (String))?")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> (String))?")
                XCTAssertEqual(closureType.outputType, "(String)")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertTrue(closureType.isVoidInput)
            XCTAssertFalse(closureType.isVoidOutput)
            XCTAssertEqual(closureType.outputs.count, 1)
            XCTAssertTrue(closureType.outputs[0] is StandardParameter)
            XCTAssertNil(closureType.outputs[0].name)
            XCTAssertNil(closureType.outputs[0].secondName)
            XCTAssertNil(closureType.outputs[0].preferredName)
            XCTAssertFalse(closureType.outputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.outputs[0].type, "String")
            XCTAssertEqual(closureType.outputs[0].typeWithoutAttributes, "String")
            XCTAssertFalse(closureType.outputs[0].isOptional)
            XCTAssertFalse(closureType.outputs[0].variadic)
            XCTAssertFalse(closureType.outputs[0].isInOut)
            XCTAssertEqual(closureType.outputs[0].description, "String")
            // Outputs have dedicated tests
        }
    }

    func test_singleOptionalPrimitiveOutput() throws {
        let source = #"""
        let voidOutput: () -> String?
        let voidOutput: (() -> String?)
        let voidOutput: (() -> String?)?
        let voidOutput: () -> (String?)
        let voidOutput: (() -> (String?))
        let voidOutput: (() -> (String?))?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "() -> String?")
                XCTAssertEqual(declaration.description, "let voidOutput: () -> String?")
                XCTAssertEqual(closureType.outputType, "String?")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> String?)")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> String?)")
                XCTAssertEqual(closureType.outputType, "String?")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> String?)?")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> String?)?")
                XCTAssertEqual(closureType.outputType, "String?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            case 3:
                XCTAssertEqual(declaration.typeAnnotation, "() -> (String?)")
                XCTAssertEqual(declaration.description, "let voidOutput: () -> (String?)")
                XCTAssertEqual(closureType.outputType, "(String?)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 4:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (String?))")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> (String?))")
                XCTAssertEqual(closureType.outputType, "(String?)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 5:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (String?))?")
                XCTAssertEqual(declaration.description, "let voidOutput: (() -> (String?))?")
                XCTAssertEqual(closureType.outputType, "(String?)")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertTrue(closureType.isVoidInput)
            XCTAssertFalse(closureType.isVoidOutput)
            XCTAssertEqual(closureType.outputs.count, 1)
            XCTAssertTrue(closureType.outputs[0] is StandardParameter)
            XCTAssertNil(closureType.outputs[0].name)
            XCTAssertNil(closureType.outputs[0].secondName)
            XCTAssertNil(closureType.outputs[0].preferredName)
            XCTAssertFalse(closureType.outputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.outputs[0].type, "String?")
            XCTAssertEqual(closureType.outputs[0].typeWithoutAttributes, "String?")
            XCTAssertTrue(closureType.outputs[0].isOptional)
            XCTAssertFalse(closureType.outputs[0].variadic)
            XCTAssertFalse(closureType.outputs[0].isInOut)
            XCTAssertEqual(closureType.outputs[0].description, "String?")
            // Outputs have dedicated tests
        }
    }

    func test_multiplePrimitiveOutput() throws {
        let source = #"""
        let tupleOutput: () -> (String, Int?)
        let tupleOutput: (() -> (String, Int?))
        let tupleOutput: (() -> (String, Int?))?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "() -> (String, Int?)")
                XCTAssertEqual(declaration.description, "let tupleOutput: () -> (String, Int?)")
                XCTAssertEqual(closureType.outputType, "(String, Int?)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (String, Int?))")
                XCTAssertEqual(declaration.description, "let tupleOutput: (() -> (String, Int?))")
                XCTAssertEqual(closureType.outputType, "(String, Int?)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (String, Int?))?")
                XCTAssertEqual(declaration.description, "let tupleOutput: (() -> (String, Int?))?")
                XCTAssertEqual(closureType.outputType, "(String, Int?)")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertTrue(closureType.isVoidInput)
            XCTAssertFalse(closureType.isVoidOutput)
            XCTAssertEqual(closureType.outputs.count, 2)
            // String
            XCTAssertTrue(closureType.outputs[0] is StandardParameter)
            XCTAssertNil(closureType.outputs[0].name)
            XCTAssertNil(closureType.outputs[0].secondName)
            XCTAssertNil(closureType.outputs[0].preferredName)
            XCTAssertFalse(closureType.outputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.outputs[0].type, "String")
            XCTAssertEqual(closureType.outputs[0].typeWithoutAttributes, "String")
            XCTAssertFalse(closureType.outputs[0].isOptional)
            XCTAssertFalse(closureType.outputs[0].variadic)
            XCTAssertFalse(closureType.outputs[0].isInOut)
            XCTAssertEqual(closureType.outputs[0].description, "String")
            // Int
            XCTAssertTrue(closureType.outputs[1] is StandardParameter)
            XCTAssertNil(closureType.outputs[1].name)
            XCTAssertNil(closureType.outputs[1].secondName)
            XCTAssertNil(closureType.outputs[1].preferredName)
            XCTAssertFalse(closureType.outputs[1].isLabelOmitted)
            XCTAssertEqual(closureType.outputs[1].type, "Int?")
            XCTAssertEqual(closureType.outputs[1].typeWithoutAttributes, "Int?")
            XCTAssertTrue(closureType.outputs[1].isOptional)
            XCTAssertFalse(closureType.outputs[1].variadic)
            XCTAssertFalse(closureType.outputs[1].isInOut)
            XCTAssertEqual(closureType.outputs[1].description, "Int?")
            // Outputs have dedicated tests
        }
    }

    func test_wrappedTupleOutput() throws {
        let source = #"""
        let tupleOutput: () -> ((String, Int?))
        let tupleOutput: (() -> ((String, Int?)))
        let tupleOutput: (() -> ((String, Int?)))?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "() -> ((String, Int?))")
                XCTAssertEqual(declaration.description, "let tupleOutput: () -> ((String, Int?))")
                XCTAssertEqual(closureType.outputType, "((String, Int?))")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> ((String, Int?)))")
                XCTAssertEqual(declaration.description, "let tupleOutput: (() -> ((String, Int?)))")
                XCTAssertEqual(closureType.outputType, "((String, Int?))")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> ((String, Int?)))?")
                XCTAssertEqual(declaration.description, "let tupleOutput: (() -> ((String, Int?)))?")
                XCTAssertEqual(closureType.outputType, "((String, Int?))")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertTrue(closureType.isVoidInput)
            XCTAssertFalse(closureType.isVoidOutput)
            XCTAssertEqual(closureType.outputs.count, 2)
            // String
            XCTAssertTrue(closureType.outputs[0] is StandardParameter)
            XCTAssertNil(closureType.outputs[0].name)
            XCTAssertNil(closureType.outputs[0].secondName)
            XCTAssertNil(closureType.outputs[0].preferredName)
            XCTAssertFalse(closureType.outputs[0].isLabelOmitted)
            XCTAssertEqual(closureType.outputs[0].type, "String")
            XCTAssertEqual(closureType.outputs[0].typeWithoutAttributes, "String")
            XCTAssertFalse(closureType.outputs[0].isOptional)
            XCTAssertFalse(closureType.outputs[0].variadic)
            XCTAssertFalse(closureType.outputs[0].isInOut)
            XCTAssertEqual(closureType.outputs[0].description, "String")
            // Int
            XCTAssertTrue(closureType.outputs[1] is StandardParameter)
            XCTAssertNil(closureType.outputs[1].name)
            XCTAssertNil(closureType.outputs[1].secondName)
            XCTAssertNil(closureType.outputs[1].preferredName)
            XCTAssertFalse(closureType.outputs[1].isLabelOmitted)
            XCTAssertEqual(closureType.outputs[1].type, "Int?")
            XCTAssertEqual(closureType.outputs[1].typeWithoutAttributes, "Int?")
            XCTAssertTrue(closureType.outputs[1].isOptional)
            XCTAssertFalse(closureType.outputs[1].variadic)
            XCTAssertFalse(closureType.outputs[1].isInOut)
            XCTAssertEqual(closureType.outputs[1].description, "Int?")
            // Outputs have dedicated tests
        }
    }

    func test_closureOutput() throws {
        let source = #"""
        let closureOutput: () -> (() -> Void)
        let closureOutput: (() -> (() -> Void))
        let closureOutput: (() -> (() -> Void))?
        let closureOutput: () -> (() -> Void?)
        let closureOutput: (() -> (() -> Void?))
        let closureOutput: (() -> (() -> Void?))?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "() -> (() -> Void)")
                XCTAssertEqual(declaration.description, "let closureOutput: () -> (() -> Void)")
                XCTAssertEqual(closureType.outputType, "(() -> Void)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.outputs[0].type, "() -> Void")
                XCTAssertEqual(closureType.outputs[0].typeWithoutAttributes, "() -> Void")
                XCTAssertFalse(closureType.outputs[0].isOptional)
                XCTAssertEqual(closureType.outputs[0].description, "() -> Void")
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (() -> Void))")
                XCTAssertEqual(declaration.description, "let closureOutput: (() -> (() -> Void))")
                XCTAssertEqual(closureType.outputType, "(() -> Void)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.outputs[0].type, "() -> Void")
                XCTAssertEqual(closureType.outputs[0].typeWithoutAttributes, "() -> Void")
                XCTAssertFalse(closureType.outputs[0].isOptional)
                XCTAssertEqual(closureType.outputs[0].description, "() -> Void")
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (() -> Void))?")
                XCTAssertEqual(declaration.description, "let closureOutput: (() -> (() -> Void))?")
                XCTAssertEqual(closureType.outputType, "(() -> Void)")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.outputs[0].type, "() -> Void")
                XCTAssertEqual(closureType.outputs[0].typeWithoutAttributes, "() -> Void")
                XCTAssertFalse(closureType.outputs[0].isOptional)
                XCTAssertEqual(closureType.outputs[0].description, "() -> Void")
            case 3:
                XCTAssertEqual(declaration.typeAnnotation, "() -> (() -> Void?)")
                XCTAssertEqual(declaration.description, "let closureOutput: () -> (() -> Void?)")
                XCTAssertEqual(closureType.outputType, "(() -> Void?)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.outputs[0].type, "() -> Void?")
                XCTAssertEqual(closureType.outputs[0].typeWithoutAttributes, "() -> Void?")
                XCTAssertFalse(closureType.outputs[0].isOptional)
                XCTAssertEqual(closureType.outputs[0].description, "() -> Void?")
            case 4:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (() -> Void?))")
                XCTAssertEqual(declaration.description, "let closureOutput: (() -> (() -> Void?))")
                XCTAssertEqual(closureType.outputType, "(() -> Void?)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.outputs[0].type, "() -> Void?")
                XCTAssertEqual(closureType.outputs[0].typeWithoutAttributes, "() -> Void?")
                XCTAssertFalse(closureType.outputs[0].isOptional)
                XCTAssertEqual(closureType.outputs[0].description, "() -> Void?")
            case 5:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (() -> Void?))?")
                XCTAssertEqual(declaration.description, "let closureOutput: (() -> (() -> Void?))?")
                XCTAssertEqual(closureType.outputType, "(() -> Void?)")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
                XCTAssertEqual(closureType.outputs[0].type, "() -> Void?")
                XCTAssertEqual(closureType.outputs[0].typeWithoutAttributes, "() -> Void?")
                XCTAssertFalse(closureType.outputs[0].isOptional)
                XCTAssertEqual(closureType.outputs[0].description, "() -> Void?")
            default: break
            }
            XCTAssertTrue(closureType.isVoidInput)
            XCTAssertFalse(closureType.isVoidOutput)
            XCTAssertEqual(closureType.outputs.count, 1)
            XCTAssertTrue(closureType.outputs[0] is ClosureParameter)
            XCTAssertNil(closureType.outputs[0].name)
            XCTAssertNil(closureType.outputs[0].secondName)
            XCTAssertNil(closureType.outputs[0].preferredName)
            XCTAssertFalse(closureType.outputs[0].isLabelOmitted)
            XCTAssertFalse(closureType.outputs[0].variadic)
            XCTAssertFalse(closureType.outputs[0].isInOut)
            let outputClosure = try XCTUnwrap(closureType.outputs[0] as? ClosureParameter)
            XCTAssertTrue(outputClosure.outputs.isEmpty)
            // Outputs have dedicated tests
        }
    }

    func test_mixedOutput() throws {
        let source = #"""
        let mixedOutput: () -> (String,  _: (name: String, age: Int), () -> Void)
        let mixedOutput: (() -> (String,  _: (name: String, age: Int), () -> Void))
        let mixedOutput: (() -> (String,  _: (name: String, age: Int), () -> Void))?
        """#

        let elements = try SyntaxParser.declarations(of: Variable.self, source: source)
        for (index, declaration) in elements.enumerated() {
            XCTAssert(declaration.attributes.isEmpty)
            XCTAssertNil(declaration.initializedValue)
            let closureType = try XCTUnwrap(declaration.closureType)
            switch index {
            case 0:
                XCTAssertEqual(declaration.typeAnnotation, "() -> (String,  _: (name: String, age: Int), () -> Void)")
                XCTAssertEqual(declaration.description, "let mixedOutput: () -> (String,  _: (name: String, age: Int), () -> Void)")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 1:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (String,  _: (name: String, age: Int), () -> Void))")
                XCTAssertEqual(declaration.description, "let mixedOutput: (() -> (String,  _: (name: String, age: Int), () -> Void))")
                XCTAssertFalse(closureType.isOptional)
                XCTAssertFalse(closureType.isAutoEscaping)
            case 2:
                XCTAssertEqual(declaration.typeAnnotation, "(() -> (String,  _: (name: String, age: Int), () -> Void))?")
                XCTAssertEqual(declaration.description, "let mixedOutput: (() -> (String,  _: (name: String, age: Int), () -> Void))?")
                XCTAssertTrue(closureType.isOptional)
                XCTAssertTrue(closureType.isAutoEscaping)
            default: break
            }
            XCTAssertTrue(closureType.isVoidInput)
            XCTAssertFalse(closureType.isVoidOutput)
            XCTAssertEqual(closureType.outputType, "(String,  _: (name: String, age: Int), () -> Void)")
            XCTAssertEqual(closureType.outputs.count, 3)
            // Standard Parameter
            XCTAssertTrue(closureType.outputs[0] is StandardParameter)
            XCTAssertNil(closureType.outputs[0].name)
            XCTAssertNil(closureType.outputs[0].secondName)
            XCTAssertNil(closureType.outputs[0].preferredName)
            XCTAssertFalse(closureType.outputs[0].isLabelOmitted)
            XCTAssertFalse(closureType.outputs[0].variadic)
            XCTAssertFalse(closureType.outputs[0].isInOut)
            XCTAssertEqual(closureType.outputs[0].type, "String")
            XCTAssertEqual(closureType.outputs[0].typeWithoutAttributes, "String")
            XCTAssertEqual(closureType.outputs[0].description, "String")
            XCTAssertTrue(closureType.outputs[1] is TupleParameter)
            XCTAssertEqual(closureType.outputs[1].name, "_")
            XCTAssertNil(closureType.outputs[1].secondName)
            XCTAssertNil(closureType.outputs[1].preferredName)
            XCTAssertTrue(closureType.outputs[1].isLabelOmitted)
            XCTAssertFalse(closureType.outputs[1].variadic)
            XCTAssertFalse(closureType.outputs[1].isInOut)
            XCTAssertEqual(closureType.outputs[1].type, "(name: String, age: Int)")
            XCTAssertEqual(closureType.outputs[1].typeWithoutAttributes, "(name: String, age: Int)")
            XCTAssertEqual(closureType.outputs[1].description, "_: (name: String, age: Int)")
            // Tuple Parameter
            let tupleType = try XCTUnwrap(closureType.outputs[1] as? TupleParameter)
            XCTAssertEqual(tupleType.arguments.count, 2)
            XCTAssertEqual(tupleType.arguments[0].name, "name")
            XCTAssertNil(tupleType.arguments[0].secondName)
            XCTAssertEqual(tupleType.arguments[0].preferredName, "name")
            XCTAssertFalse(tupleType.arguments[0].isLabelOmitted)
            XCTAssertFalse(tupleType.arguments[0].variadic)
            XCTAssertFalse(tupleType.arguments[0].isInOut)
            XCTAssertEqual(tupleType.arguments[0].type, "String")
            XCTAssertEqual(tupleType.arguments[0].typeWithoutAttributes, "String")
            XCTAssertEqual(tupleType.arguments[0].description, "name: String")
            XCTAssertEqual(tupleType.arguments[1].name, "age")
            XCTAssertNil(tupleType.arguments[1].secondName)
            XCTAssertEqual(tupleType.arguments[1].preferredName, "age")
            XCTAssertFalse(tupleType.arguments[1].isLabelOmitted)
            XCTAssertFalse(tupleType.arguments[1].variadic)
            XCTAssertFalse(tupleType.arguments[1].isInOut)
            XCTAssertEqual(tupleType.arguments[1].type, "Int")
            XCTAssertEqual(tupleType.arguments[1].typeWithoutAttributes, "Int")
            XCTAssertEqual(tupleType.arguments[1].description, "age: Int")
            // Closure Parameter
            XCTAssertTrue(closureType.outputs[2] is ClosureParameter)
            XCTAssertEqual((closureType.outputs[2] as? ClosureParameter)?.isVoidInput, true)
            XCTAssertEqual((closureType.outputs[2] as? ClosureParameter)?.isVoidOutput, true)
            XCTAssertEqual((closureType.outputs[2] as? ClosureParameter)?.isOptional, false)
        }
    }
}
