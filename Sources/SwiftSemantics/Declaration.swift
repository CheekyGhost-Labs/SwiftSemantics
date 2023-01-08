import SwiftSyntax

public struct DeclarationLocation: Equatable, Codable, Hashable {

    /// The line number the declaration was made on.
    /// 
    /// Will be `nil` if unresolvable.
    public let line: Int?

    /// The horizontal offset (column) the declaration begins at on the `line`.
    ///
    /// Will be `nil` if unresolvable.
    public let column: Int?

    /// The utf8 character offset (character index) within the parent string.
    ///
    /// Will be `nil` if unresolvable.
    public let utf8Offset: Int

    // MARK: - Lifecycle

    public init(line: Int?, offset: Int?, utf8Offset: Int) {
        self.line = line
        self.column = offset
        self.utf8Offset = utf8Offset
    }

    // MARK: - Internal

    static func empty() -> DeclarationLocation {
        return DeclarationLocation(line: nil, offset: nil, utf8Offset: 0)
    }
}

/// A Swift declaration.
public protocol Declaration {

    // MARK: - Lines

    /// The location the function declaration starts on.
    var startLocation: DeclarationLocation { get }

    /// The location the declaration closes/ends on.
    var endLocation: DeclarationLocation { get }
}

extension Declaration {

    /// Will return a range for extracting a substring by using the `utf8Offset`
    /// - Parameter string: The source string to calculate the range within.
    /// - Returns: `Range<String.Index>` or `nil` if the range is invalid within the given string.
    public func substringRange(in string: String) -> Range<String.Index>? {
        guard startLocation.utf8Offset < string.count, endLocation.utf8Offset <= string.count else { return nil }
        let startIndex = String.Index(utf16Offset: startLocation.utf8Offset, in: string)
        let endIndex = String.Index(utf16Offset: endLocation.utf8Offset, in: string)
        return Range<String.Index>(uncheckedBounds: (startIndex, endIndex))
    }

    /// Will utilise the `substringRange(in:)` method to extract the declaration from the given source.
    /// - Parameter source: The source string to extrace from.
    /// - Returns: `String` or `nil` if the bounds are invalid
    public func extractFromSource(_ source: String) -> String? {
        guard let range = substringRange(in: source) else { return nil }
        return String(source[range])
    }
}
