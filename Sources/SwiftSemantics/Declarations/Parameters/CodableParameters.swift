//
//  File.swift
//  
//
//  Created by Cheeky Ghost Labson 1/12/2022.
//

import Foundation
import SwiftSyntax

struct CodableParameters: Codable {

    struct TupleParameterItem: Codable {
        var index: Int
        var element: TupleParameter
    }

    struct StandardParameterItem: Codable {
        var index: Int
        var element: StandardParameter
    }

    struct ClosureParameterItem: Codable {
        var index: Int
        var element: ClosureParameter
    }

    var closureParameters: [ClosureParameterItem] = []

    var standardParameters: [StandardParameterItem] = []

    var tupleParameters: [TupleParameterItem] = []

    var sortedElements: [any ParameterType] {
        typealias UnwrappedItem = (index: Int, value: any ParameterType)
        var elements: [UnwrappedItem] = tupleParameters.map { ($0.index, $0.element) }
        elements += standardParameters.map { ($0.index, $0.element) }
        elements += closureParameters.map { ($0.index, $0.element) }
        elements.sort(by: { $0.index < $1.index })
        return elements.map(\.value)
    }

    mutating func append(_ element: ClosureParameter, index: Int) {
        let wrapped = ClosureParameterItem(index: index, element: element)
        closureParameters.append(wrapped)
    }

    mutating func append(_ element: TupleParameter, index: Int) {
        let wrapped = TupleParameterItem(index: index, element: element)
        tupleParameters.append(wrapped)
    }

    mutating func append(_ element: StandardParameter, index: Int) {
        let wrapped = StandardParameterItem(index: index, element: element)
        standardParameters.append(wrapped)
    }

    mutating func append(_ parameter: any ParameterType, index: Int) {
        switch parameter {
        case let item as ClosureParameter:
            append(item, index: index)
        case let item as TupleParameter:
            append(item, index: index)
        case let item as StandardParameter:
            append(item, index: index)
        default: break
        }
    }
}

func parametersEqual(_ lhs: [any ParameterType], _ rhs: [any ParameterType]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (index, element) in lhs.enumerated() {
        switch element {
        case let item as StandardParameter:
            if item != rhs[index] as? StandardParameter { return false }
        case let item as ClosureParameter:
            if item != rhs[index] as? ClosureParameter { return false }
        case let item as TupleParameter:
            if item != rhs[index] as? TupleParameter { return false }
        default:
            return false
        }
    }
    return true
}
