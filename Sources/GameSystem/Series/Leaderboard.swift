//
//  Leaderboard.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//
import Foundation

/// Leaderboard model.
struct Leaderboard: Codable {
    /// Count of games won by winning player lookup table.
    var gamesWonByPlayerName = [String: Int]()

    /// Basic initializr.
    /// - parameter playerDefs: Series players (player order unimportant).
    init(playerDefs: [VmoPlayerDef]) {
        for playerDef in playerDefs {
            gamesWonByPlayerName[playerDef.name] = 0
        }
    }

    /// Update the leaderboard with the winning player.
    mutating func gameEnded(winningPlayerName: String) {
        gamesWonByPlayerName[winningPlayerName]! += 1
    }

    /// Factory method for leaderboard view model
    var vmoLeaderboardEntries: [VmoLeaderboardEntry] {
        return gamesWonByPlayerName.keys.map { VmoLeaderboardEntry(name: $0, gamesWon: gamesWonByPlayerName[$0]!) }
                 .sorted { $0.gamesWon == $1.gamesWon ? $0.name < $1.name : $0.gamesWon > $1.gamesWon }
    }
}
