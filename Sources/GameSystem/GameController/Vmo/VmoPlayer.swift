//
//  VmoPlayer.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// View model object for the player during the game.
public struct VmoPlayer {
    /// Display name
    public let name: String
    /// Current net worth, defined as cash on hand plus value of all shares.
    public let netWorth: Int
    /// Shares in companies. Elements correlates to corresponding elements in 'activeCompanies' array
    public let activeCompanyShares: [Int]
}
