//
//  File.swift
//  
//
//  Created by Cheeky Ghost Labson 1/12/2022.
//

import SwiftSyntax

enum Utils {

    static func isLabelOmitted(_ name: String?) -> Bool {
        (name ?? "") == "_"
    }

    static func isTypeOptional(_ type: String?) -> Bool {
        (type ?? "").hasSuffix("?")
    }

    static func isClosureTypeOptional(_ type: String?) -> Bool {
        (type ?? "").hasSuffix(")?")
    }

    /// Will return the `secondName` if available, falling back to the `firstName`. If neither is available an empty string will be returned.
    static func getPreferredName(firstName: String?, secondName: String?, labelOmitted: Bool) -> String? {
        guard let secondName = secondName, !secondName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            if let firstName = firstName, !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !labelOmitted {
                return firstName
            }
            return nil
        }
        return secondName
    }

    /// Will return the `typeAnnotation` without any attributes (such as `@escaping`). If the `typeAnnotation` is `nil` then `nil` will also be returned.
    static func stripAttributes(from typeString: String?) -> String? {
        guard let input = typeString, !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return input.replacingOccurrences(of: "(\\@[\\w\\(\\)\\,]{1,}\\s{0,})|^\\s{0,}(inout\\s{0,})", with: "", options: .regularExpression)
    }

    static func isVoidType(_ type: String?) -> Bool {
        guard let type = type?.replacingOccurrences(of: " ", with: "") else { return false }
        let voidTypes = ["Void","(Void)","Void?","(Void?)","()","(())","()?","(()?)"]
        return voidTypes.contains(type)
    }

}
