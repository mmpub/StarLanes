//
//  Series.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//
import Foundation

/// Persistable series model
struct Series: Codable {
    /// Game configuration parameters, invariant throughout series.
    let gameConfig: GameConfig!
    /// House rules values, invariant throughout series.
    let houseRules: HouseRules!
    /// Player definitions, invariant throughout series.
    let playerDefs: [VmoPlayerDef]!
    /// Leaderboard model, containing unordered correlation of players with games won.
    var leaderboard: Leaderboard!
}
