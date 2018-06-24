//
//  VmoLeaderboard.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// View model object for a leaderboard entry.
/// An array of these items is presented to the front end by Magister Ludi, ranked primarily by games won, 
/// and secondarily by alphabetical order.
public struct VmoLeaderboardEntry {
    /// Player display name
    public let name: String
    /// Games won so far by this player in the series.
    public let gamesWon: Int
}
