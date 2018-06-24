//
//  GameConfig.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

import Foundation

/// Game Configuration parameters. Invariant during series.
public struct GameConfig: Codable, Equatable {
    /// Number of columns in Galaxy Map for each game in the series.
    let mapColumnCount: Int
    /// Number of rows in Galaxy Map for each game in the series.
    let mapRowCount: Int
    /// Number of stars on the map for each game in the series.
    let starCount: Int
    /// Number of shipping companies in the series.
    let shippingCompanyCount: Int
    /// Number of company tokens on the map to declare a company "safe" from being merged into another company.
    let safeTokenCount: Int
    /// Once a company has this many tokens on the map, the lead player can call the game.
    let endGameTokenCount: Int
}

extension GameConfig {

    /// Basic game configuration.
    static var basic: GameConfig {
        return GameConfig(
                  mapColumnCount: 12,
                  mapRowCount: 9,
                  starCount: 8,
                  shippingCompanyCount: 5,
                  safeTokenCount: 11,
                  endGameTokenCount: 41
               )
    }

    /// Deluxe game configuration.
    static var deluxe: GameConfig {
        return GameConfig(
                   mapColumnCount: 16,
                   mapRowCount: 9,
                   starCount: 12,
                   shippingCompanyCount: 10,
                   safeTokenCount: 15,
                   endGameTokenCount: 55
               )
    }

    /// Minimum game configuration values, used as limits during game configuration.
    static var min: GameConfig {
        return GameConfig(
                   mapColumnCount: 7,
                   mapRowCount: 5,
                   starCount: 0,
                   shippingCompanyCount: 5,
                   safeTokenCount: 5,
                   endGameTokenCount: 15
               )
    }

    /// Maximum game configuration values, used as limits during game configuration.
    static var max: GameConfig {
        return GameConfig(
                   mapColumnCount: 20,
                   mapRowCount: 9,
                   starCount: 15,
                   shippingCompanyCount: 10,
                   safeTokenCount: 65,
                   endGameTokenCount: 180
               )
    }
}
