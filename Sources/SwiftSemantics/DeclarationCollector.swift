import SwiftSyntax

/**
 A Swift syntax visitor that collects declarations.

 Create an instance of `DeclarationCollector`
 and pass it by reference when walking an AST created by `SyntaxParser`
 to collect any visited declarations:

 ```swift
 import SwiftSyntax
 import SwiftSemantics

 let source = #"enum E {}"#

 var collector = DeclarationCollector()
 let tree = try SyntaxParser.parse(source: source)
 tree.walk(&collector)

 collector.enumerations.first?.name // "E"
 ```
 */
open class DeclarationCollector: SyntaxVisitor {
    /// The collected associated type declarations.
    public private(set) var associatedTypes: [AssociatedType] = []

    /// The collected class declarations.
    public private(set) var classes: [Class] = []

    /// The collected conditional compilation block declarations.
    public private(set) var conditionalCompilationBlocks: [ConditionalCompilationBlock] = []

    /// The collected deinitializer declarations.
    public private(set) var deinitializers: [Deinitializer] = []

    /// The collected enumeration declarations.
    public private(set) var enumerations: [Enumeration] = []

    /// The collected enumeration case declarations.
    public private(set) var enumerationCases: [Enumeration.Case] = []

    /// The collected extension declarations.
    public private(set) var extensions: [Extension] = []

    /// The collected function declarations.
    public private(set) var functions: [Function] = []

    /// The collected import declarations.
    public private(set) var imports: [Import] = []

    /// The collected initializer declarations.
    public private(set) var initializers: [Initializer] = []

    /// The collected operator declarations.
    public private(set) var operators: [Operator] = []

    /// The collected precedence group declarations.
    public private(set) var precedenceGroups: [PrecedenceGroup] = []

    /// The collected protocol declarations.
    public private(set) var protocols: [Protocol] = []

    /// The collected structure declarations.
    public private(set) var structures: [Structure] = []

    /// The collected subscript declarations.
    public private(set) var subscripts: [Subscript] = []

    /// The collected type alias declarations.
    public private(set) var typealiases: [Typealias] = []

    /// The collected variable declarations.
    public private(set) var variables: [Variable] = []

    /// Source line location converter assigned when the `walk(_:sourceBuffer)` is used.
    var lineConverter: SourceLocationConverter?

    public convenience init() {
        self.init(viewMode: .fixedUp)
    }

    // MARK: - SyntaxVisitor

    /// Will walk through the syntax as normal but use the provided source buffer to resolve what start/end lines a declaration is on.
    ///
    /// **Note:** If the standard `walk(_:)` method is used **all lines will be 0**
    /// - Parameters:
    ///   - node: The node to walk through.
    ///   - sourceBuffer: The source the syntax was parsed from.
    public func walk(_ node: SourceFileSyntax, sourceBuffer: String) {
        lineConverter = SourceLocationConverter(file: sourceBuffer, tree: node)
        walk(node)
        lineConverter = nil
    }

    /// Called when visiting an `AssociatedtypeDeclSyntax` node
    public override func visit(_ node: AssociatedtypeDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = AssociatedType(node)
        assignLocations(&result, node: node)
        associatedTypes.append(result)
        return .skipChildren
    }

    /// Called when visiting a `ClassDeclSyntax` node
    public override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = Class(node)
        assignLocations(&result, node: node)
        classes.append(result)
        return .visitChildren
    }

    /// Called when visiting a `DeinitializerDeclSyntax` node
    public override func visit(_ node: DeinitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = Deinitializer(node)
        assignLocations(&result, node: node)
        deinitializers.append(result)
        return .skipChildren
    }

    /// Called when visiting an `EnumDeclSyntax` node
    public override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = Enumeration(node)
        assignLocations(&result, node: node)
        enumerations.append(result)
        return .visitChildren
    }

    /// Called when visiting an `EnumCaseDeclSyntax` node
    public override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
        let results = Enumeration.Case.cases(from: node)
        for var item in results {
            assignLocations(&item, node: node)
            enumerationCases.append(item)
        }
        return .skipChildren
    }

    /// Called when visiting an `ExtensionDeclSyntax` node
    public override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = Extension(node)
        assignLocations(&result, node: node)
        extensions.append(result)
        return .visitChildren
    }

    /// Called when visiting a `FunctionDeclSyntax` node
    public override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = Function(node)
        assignLocations(&result, node: node)
        functions.append(result)
        return .skipChildren
    }

    /// Called when visiting an `IfConfigDeclSyntax` node
    public override func visit(_ node: IfConfigDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = ConditionalCompilationBlock(node)
        assignLocations(&result, node: node)
        conditionalCompilationBlocks.append(result)
        return .visitChildren
    }

    /// Called when visiting an `ImportDeclSyntax` node
    public override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = Import(node)
        assignLocations(&result, node: node)
        imports.append(result)
        return .skipChildren
    }

    /// Called when visiting an `InitializerDeclSyntax` node
    public override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = Initializer(node)
        assignLocations(&result, node: node)
        initializers.append(result)
        return .skipChildren
    }

    /// Called when visiting an `OperatorDeclSyntax` node
    public override func visit(_ node: OperatorDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = Operator(node)
        assignLocations(&result, node: node)
        operators.append(result)
        return .skipChildren
    }

    /// Called when visiting a `PrecedenceGroupDeclSyntax` node
    public override func visit(_ node: PrecedenceGroupDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = PrecedenceGroup(node)
        assignLocations(&result, node: node)
        precedenceGroups.append(result)
        return .skipChildren
    }

    /// Called when visiting a `ProtocolDeclSyntax` node
    public override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = Protocol(node)
        assignLocations(&result, node: node)
        protocols.append(result)
        return .visitChildren
    }

    /// Called when visiting a `SubscriptDeclSyntax` node
    public override  func visit(_ node: SubscriptDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = Subscript(node)
        assignLocations(&result, node: node)
        subscripts.append(result)
        return .skipChildren
    }

    /// Called when visiting a `StructDeclSyntax` node
    public override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        var result = Structure(node)
        assignLocations(&result, node: node)
        structures.append(result)
        return .visitChildren
    }

    /// Called when visiting a `TypealiasDeclSyntax` node
    public override func visit(_ node: TypealiasDeclSyntax) -> SyntaxVisitorContinueKind {
        var alias = Typealias(node)
        assignLocations(&alias, node: node)
        typealiases.append(alias)
        return .skipChildren
    }

    /// Called when visiting a `VariableDeclSyntax` node
    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        let results = Variable.variables(from: node)
        for var variable in results {
            assignLocations(&variable, node: node)
            variables.append(variable)
        }
        return .skipChildren
    }

    // MARK: - Line Bound Helpers

    func assignLocations<T: Declaration>(_ element: inout T, node: SyntaxProtocol) {
        let bounds = locationsForNode(node)
        switch element {
        case var item as AssociatedType:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Class:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as ConditionalCompilationBlock:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Deinitializer:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Enumeration:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Enumeration.Case:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Extension:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Function:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Import:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Initializer:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Operator:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as PrecedenceGroup:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as `Protocol`:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Structure:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Subscript:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Typealias:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        case var item as Variable:
            item.startLocation = bounds.start
            item.endLocation = bounds.end
            element = item as! T
        default:
            return
        }
    }

    func locationsForNode(_ node: SyntaxProtocol) -> (start: DeclarationLocation, end: DeclarationLocation) {
        guard
            let converter = lineConverter,
            let firstToken = node.firstToken,
            let lastToken = node.lastToken
        else {
            return (.empty(), .empty())
        }
        let start = firstToken.startLocation(converter: converter)
        let end = lastToken.endLocation(converter: converter)
        // Line/Column is supposed to be -1 but it does not honour that.
        let normalisedLocation: (Int?) -> Int? = { location in
            guard let number = location else {
                return nil
            }
            return max(0, number - 1)
        }
        let startLocation = DeclarationLocation(
            line: normalisedLocation(start.line),
            offset: normalisedLocation(start.column),
            utf8Offset: start.offset
        )
        let endLocation = DeclarationLocation(
            line: normalisedLocation(end.line),
            offset: normalisedLocation(end.column),
            utf8Offset: end.offset
        )
        return (startLocation, endLocation)
    }
}
