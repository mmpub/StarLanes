//
//  Map.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//
import Foundation

/// Models the galaxy map
final class GalaxyMap {
    /// Column count in the map
    let columnCount: Int
    /// Row count in the map
    let rowCount: Int
    /// Token values in the map. This is private, and accessed by getter/setter that protects against invalid indices.
    private var map: [[Token?]]

    /// Basic initializer.
    /// - parameter columnCount: Column count of the map.
    /// - parameter rowCount: Row count of the map
    init(columnCount: Int, rowCount: Int) {
        self.columnCount = columnCount
        self.rowCount    = rowCount
        map = Array(repeating: Array(repeating: nil, count: rowCount), count: columnCount)
    }

    func clone() -> GalaxyMap {
        let result = GalaxyMap(columnCount: columnCount, rowCount: rowCount)
        for row in 0 ..< rowCount {
            for column in 0 ..< columnCount {
                result.map[column][row] = map[column][row]
            }
        }
        return result
    }

    /// Mark up galaxy map with coordinate options.
    /// - parameter coordinateOptions: array of coordinate models.
    /// - returns: Copy of galaxy map, marked up with player's coordinate options.
    func markedUp(coordinateOptions: [Coordinate]) -> GalaxyMap {
        let clonedGalaxyMap = clone()

        // Add marker tokens to map
        var markerIndex = 1
        for coordinate in coordinateOptions {
            clonedGalaxyMap[coordinate] = .marker(markerIndex)
            markerIndex += 1
        }

        return clonedGalaxyMap
    }

    /// Galaxy map coordinate getter and setter.
    /// These guard against invalid coordinates, which occur when naively accessing cardinally adjacent coordinates.
    subscript(coordinate: Coordinate) -> Token? {
        get {
            if coordinate.column < 0 || coordinate.column >= columnCount || coordinate.row < 0 || coordinate.row >= rowCount {
                return nil
            }
            return map[coordinate.column][coordinate.row]
        }

        set(token) {
            if coordinate.column >= 0 && coordinate.column < columnCount && coordinate.row >= 0 && coordinate.row < rowCount {
                map[coordinate.column][coordinate.row] = token
            }
        }
    }
}

extension GalaxyMap: Codable {
    enum CodingKeys: String, CodingKey {
        case columnCount
        case rowCount
        case map
    }

    convenience init(from decoder: Decoder) throws {
        let container      = try decoder.container(keyedBy: CodingKeys.self)
        let mapColumnCount = try container.decode(Int.self, forKey: .columnCount)
        let mapRowCount    = try container.decode(Int.self, forKey: .rowCount)
        let mapString      = try container.decode(String.self, forKey: .map)
        self.init(columnCount: mapColumnCount, rowCount: mapRowCount)
        var index = 0
        for row in 0 ..< rowCount {
            for column in 0 ..< columnCount {
                let stringIndex = mapString.index(mapString.startIndex, offsetBy: index)
                map[column][row] = Token(String(mapString[stringIndex]))
                index += 1
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(columnCount, forKey: .columnCount)
        try container.encode(rowCount, forKey: .rowCount)

        var mapString = [String]()
        for row in 0 ..< rowCount {
            for column in 0 ..< columnCount {
                mapString.append(map[column][row] != nil ? String(describing: map[column][row]!) : ".")
            }
        }
        try container.encode(mapString.joined(separator: ""), forKey: .map)
    }
}
