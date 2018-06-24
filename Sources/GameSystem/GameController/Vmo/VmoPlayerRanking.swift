//
//  VmoPlayerRanking.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// View model object containing the ranked players. Used by front end to present ranking list.
public struct VmoPlayerRanking {
    /// Active companies in alphabetical order
    public let activeCompanies: [VmoCompany]
    /// Players ranked by net worth.
    public let rankedPlayers: [VmoPlayer]
}

extension VmoPlayerRanking {
    /// VmoPlayerRanking initialzer.
    /// - parameter game: Game model information.
    /// - parameter series: Series model information.
    init (game: Game, series: Series) {
        activeCompanies =  game.model.activeCompanies.map { VmoCompany(company: $0) }
        rankedPlayers   =  zip(game.model.players, game.model.netWorths)
                              .sorted { $0.1 > $1.1 }
                              .map {
                                  let (player, netWorth) = $0
                                  return VmoPlayer(
                                     name: series.playerDefs[player.index].name,
                                     netWorth: netWorth,
                                     activeCompanyShares: game.model.activeCompanies.map { player.shares[$0.index] }
                                   )
                               }
    }
}
