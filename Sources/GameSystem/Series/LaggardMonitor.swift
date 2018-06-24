//
//  LaggardMonitor.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//
import Foundation

/// The LaggardMonitor heuristically determines when to offer concession. It doesn't want to offer it too early,
/// before any merges and before enough rounds have been played. The lagging player may jump ahead after the first
/// merge, so we wait until a merge occurs and a minimum number of rounds have been played.
struct LaggardMonitor: Codable {
    private var playerCount: Int
    private var humanPlayerCount: Int
    private var isComputer: [Bool]
    private let minConcessionRound: Int
    private var netWorthRatios = [[Double]]()
    private var roundCount = 0
    private var hasMergeOccurred = false
    private var lastActiveCompanyCount = 0

    /// Basic initializer.
    /// - parameter gameConfig: Series game configuration model.
    /// - parameter isComputer: Boolean array correlating to player array indicating which players are computer-controlled.
    init(gameConfig: GameConfig, isComputer: [Bool]) {
        self.playerCount      = isComputer.count
        self.humanPlayerCount = isComputer.filter { $0 == false }.count
        self.isComputer       = isComputer
        // Heuristic (two players) evaluates to 30 for basic map; 40 for deluxe map
        minConcessionRound    = Int((Double(gameConfig.mapColumnCount * gameConfig.mapRowCount) / (1.8 * Double(playerCount))) + 0.5)
    }

    /// Heuristically analyzes the game from the point of a given player to determine if winning is almost (or maybe actually) impossible.
    /// - parameter playerIndex: index of player in game player array
    /// - returns: true if player should be offered a chance to concede the game.
    func isPlayerLagging(playerIndex: Int) -> Bool {
        if (playerCount == 2 || humanPlayerCount == 1) && roundCount >= minConcessionRound && hasMergeOccurred {
            // See if player is lagging, and offer concession.
            let last       = netWorthRatios[netWorthRatios.count - 1][playerIndex]
            let secondLast = netWorthRatios[netWorthRatios.count - 2][playerIndex]
            let thirdLast  = netWorthRatios[netWorthRatios.count - 3][playerIndex]
            let qualifyForConcession = last <= secondLast && secondLast <= thirdLast && (secondLast <= 0.4 || thirdLast <= 0.5)
            if humanPlayerCount == 1 && playerCount > 2 {
                // only offer to human (any rank) or second place computer player
                let rankedPlayerIndices = zip(0 ..< playerCount, netWorthRatios.last!).sorted { $0.1 > $1.1 }.map { $0.0 }
                return (isComputer[playerIndex] == false || (isComputer[rankedPlayerIndices[0]] == false && rankedPlayerIndices[1] == playerIndex)) ? qualifyForConcession : false
            } else {
                return qualifyForConcession
            }
        }
        return false
    }

    /// Updates internal variable used in the heuristics such as "has a company merged" and records net worths to later analyze trends.
    /// - parameter gameModel: The game to analyze.
    mutating func endRound(gameModel: GameModel) {
        // Note: This heuristic will miss some initial merges when subsequent players in the same round forms another company, so the company count doesn't go down.
        // But in general gameplay, this will catch merges prior to the minimum concession round count.
        let activeCompanyCount = gameModel.activeCompanies.count
        if activeCompanyCount < lastActiveCompanyCount {
            hasMergeOccurred = true
        }
        lastActiveCompanyCount = activeCompanyCount
        roundCount += 1
        let netWorths = gameModel.netWorths
        netWorthRatios.append(netWorths.map { Double($0) / Double(netWorths.sorted(by: >).first!) })
    }
}
