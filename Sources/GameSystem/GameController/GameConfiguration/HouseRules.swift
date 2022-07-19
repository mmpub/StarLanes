//
//  HouseRules.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

import Foundation

/// House rules values. Invariant during series.
public struct HouseRules: Codable, Equatable {
    /// The cash each human player is given at the start of every game in the series.
    let humanInitialCash: Int
    /// The cash each computer player is given at the start of every game in the series.
    let computerInitialCash: Int
    /// Number of coordinates dealt to each player at the start of the game.
    let playerCoordinateOptionCount: Int
    /// Number of shares given to the founder as a bonus when creating a company.
    let founderShareBonus: Int
    /// Value of adjacent star to share price. Stars are only calculated once for multiple adjacencies.
    let shareValueAdjacentStar: Int
    /// Value of adjacent token to share price.
    let shareValueAdjacentToken: Int
    /// Each round, each player gets paid a dividend. The dividend is calculated as: all shares * share values * dividend percent.
    let dividendPercent: Int
    /// Upon merger, this many multiples of defunct company share value is split proportionaly amongst outstanding share holders
    let mergeBonusShareValueMultiple: Int
    /// Determines whether the player order is random or fixed for every game in the series.
    let isPlayerOrderRandom: Bool
}

extension HouseRules {

    // Default house rules.
    static var `default`:HouseRules {
        return HouseRules(
                humanInitialCash: 6000,
                computerInitialCash: 6000,
                playerCoordinateOptionCount: 5,
                founderShareBonus: 5,
                shareValueAdjacentStar: 500,
                shareValueAdjacentToken: 100,
                dividendPercent: 5,
                mergeBonusShareValueMultiple: 10,
                isPlayerOrderRandom: true
            )
    }

    /// Minimum house rules values, integer values used as limits during game configuration.
    static var min: HouseRules {
        return HouseRules(
                humanInitialCash: 3000,
                computerInitialCash: 3000,
                playerCoordinateOptionCount: 3,
                founderShareBonus: 0,
                shareValueAdjacentStar: 200,
                shareValueAdjacentToken: 10,
                dividendPercent: 5,
                mergeBonusShareValueMultiple: 1,
                isPlayerOrderRandom: true
            )
    }

    /// Maximum house rules values, integer values used as limits during game configuration.
    static var max: HouseRules {
        return HouseRules(
                humanInitialCash: 10_000,
                computerInitialCash: 10_000,
                playerCoordinateOptionCount: 9,
                founderShareBonus: 10,
                shareValueAdjacentStar: 1000,
                shareValueAdjacentToken: 200,
                dividendPercent: 10,
                mergeBonusShareValueMultiple: 20,
                isPlayerOrderRandom: true
            )
    }
}
