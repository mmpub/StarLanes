//
//  Game.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//
import Foundation

/// Persistable container of information relating to an in-progress game.
struct Game: Codable {
    /// Current game model
    var model: GameModel
    /// Current laggard monitor
    var laggardMonitor: LaggardMonitor
    /// A record of companies declared safe, preventing multiple announcements for the same company.
    var companiesDeclaredSafe: [Bool]
    /// Current index of player taking turn.
    var playerIndex: Int
    // For non-randomized player order, this will be 0, 1, 2, 3
    var playerOrder: [Int]

    /// Current player index for series player definition array.
    var currentPlayerIndex: Int {
        return playerOrder[playerIndex]
    }
}
