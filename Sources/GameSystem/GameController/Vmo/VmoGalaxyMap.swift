//
//  VmoGalaxyMap.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// View model object of the galaxy map.

public struct VmoGalaxyMap {
    /// Number of columns in map
    public let columnCount: Int
    /// Number of rows in map
    public let rowCount: Int
    /// Two-dimensional array of one-character strings representing the galaxy map.
    public let map: [[String]]
}

extension VmoGalaxyMap {
    /// VmoGalaxyMap initializer.
    /// - parameter galaxyMap: GalaxyMap model to transform into this view model.
    init(galaxyMap: GalaxyMap) {
        columnCount  = galaxyMap.columnCount
        rowCount = galaxyMap.rowCount
        var map = Array(repeating: Array(repeating: ".", count: rowCount), count: columnCount)
        for row in 0 ..< rowCount {
            for column in 0 ..< columnCount {
                let tokenName: String
                let token = galaxyMap[Coordinate(row: row, column: column)]
                if  token == nil {
                    tokenName = "."
                } else {
                    switch token! {
                    case .star:
                        tokenName = "*"

                    case .outpost:
                        tokenName = "+"

                    case let .company(companyID):
                        let letterA = UInt8(65)
                        tokenName = String(UnicodeScalar(letterA + UInt8(companyID)))

                    case let .marker(marker):
                        tokenName = "\(marker)"
                    }
                }
                map[column][row] = tokenName
            }
        }
        self.map = map
    }
}
