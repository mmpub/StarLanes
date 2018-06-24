//
//  Coordinate.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//
import Foundation

/// Coordinate location record.
public struct Coordinate: Codable, Equatable, Hashable {
    let row: Int
    let column: Int
}

extension Coordinate {
    /// - returns: An array of adjacent coordinates. Illegal (off-map) coordinates are handled in the GalaxyMap coorinate getter/setter.
    var adjacentCoordinates: [Coordinate] {
        return [
            Coordinate(row: row-1, column: column),
            Coordinate(row: row+1, column: column),
            Coordinate(row: row, column: column-1),
            Coordinate(row: row, column: column+1)
        ]
    }
}

extension Coordinate: CustomStringConvertible {
    public var description: String {
        let number1 = UInt8(49) // 49 is ASCII code for '1'
        let letterA = UInt8(65) // 65 is ASCII code for 'A'
        return String(UnicodeScalar(number1 + UInt8(row))) + String(UnicodeScalar(letterA + UInt8(column)))
    }
}

extension Coordinate: LosslessStringConvertible {
    public init?(_ description: String) {
        let chars = description.utf8.map { UInt8($0) }
        if chars.count != 2 { return nil }
        let number1 = UInt8(49)
        let letterA = UInt8(65)
        let row = Int(chars[0] - number1)
        let column = Int(chars[1] - letterA)
        self = Coordinate(row: row, column: column)
    }
}
