//
//  GameModel.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//
import Foundation

/// The master model data repository of the game.
/// Each game in a series has its own game model.
struct GameModel: Codable {

    // MARK: Game Configuration

    /// Game configuration parameters. Invariant throughout the series.
    private let gameConfig: GameConfig
    /// House rules values. Invariant throughout the series.
    private let houseRules: HouseRules

    // MARK: Game State

    /// Internal record of the current player index, controlled by the Magister Ludi.
    /// This will not increment sequentially with randomized player order.
    private(set) var currentPlayerIndex = 0
    /// The galaxy map used in the game.
    private(set) var galaxyMap: GalaxyMap
    /// Coordinates of all black holes in the galaxy map.
    private var blackHoleCoordinates: [Coordinate]
    /// The player models used in the game.
    /// Note: these models don't have 'name' fields because they're not user-facing VMO's.
    private(set) var players: [Player]
    /// The company models used in the game. This holds all companies, active or not.
    /// Note: these models don't have 'name' fields because they're not user-facing VMO's.
    private(set) var companies: [Company]
    /// The coordinate dealer for the game.
    private var dealer: Dealer
    /// Convenient set of all coordinates (order unimportant) used in functional comprehensions and providing default (shuffled) set to dealer.
    private let allCoordinates: [Coordinate]

    /// Basic initializer.
    /// - parameter gameConfig: Series game configuration parameters.
    /// - parameter houseRules: Series house rule values.
    /// - parameter playerCount: Number of players (computers + humans) in the game.
    /// - parameter isComputer: Array correlating to player array to designate computer-controlled players.
    /// - parameter fixedCoordinateStack: Optionally provided by multi-device, multiplayer games; test suites; etc.
    init (gameConfig: GameConfig, houseRules: HouseRules, playerCount: Int, isComputer: [Bool], fixedCoordinateStack: [Coordinate]? = nil) {
        let (columnCount, rowCount) = (gameConfig.mapColumnCount, gameConfig.mapRowCount)
        let allCoordinates = (0 ..< (columnCount * rowCount)).reduce([Coordinate]()) {
            let (row, column) = ($1 / columnCount, $1 % columnCount)
            var array = $0
            array.append(Coordinate(row: row, column: column))
            return array
        }
        let galaxyMap = GalaxyMap(columnCount: columnCount, rowCount: rowCount)
        var dealer = Dealer(coordinateStack: fixedCoordinateStack ?? allCoordinates.shuffled())

        self.gameConfig = gameConfig
        self.houseRules = houseRules
        self.galaxyMap = galaxyMap
        players = (0 ..< playerCount).map {
                    Player(
                            index: $0,
                            cash: isComputer[$0] ? houseRules.computerInitialCash : houseRules.humanInitialCash,
                            shippingCompanyCount: gameConfig.shippingCompanyCount,
                            coordinateOptions: dealer.dealCoordinates(count: houseRules.playerCoordinateOptionCount)
                          )
        }
        companies = (0 ..< gameConfig.shippingCompanyCount).map { Company(index: $0) }
        self.dealer = dealer
        self.allCoordinates = allCoordinates
        self.blackHoleCoordinates = self.dealer.dealCoordinates(count: gameConfig.blackHoleCount)

        // Deal star tokens to galaxy map
        self.dealer.dealCoordinates(count: gameConfig.starCount).forEach { self.galaxyMap[$0] = .star }

        // Deal black hole tokens to galaxy map
        self.blackHoleCoordinates.forEach { self.galaxyMap[$0] = .blackHole }
    }

    func clone() -> GameModel {
        var result = self
        result.galaxyMap = result.galaxyMap.clone()
        return result
    }

    /// Return alphabetized list of active companies.
    var activeCompanies: [Company] {
        return companies.filter { $0.isActive }
    }

    /// Return array of player net worths. Array elements correspond to player model array.
    var netWorths: [Int] {
        return players.map { player in companies.indices.reduce(player.cash) { $0 + player.shares[companies[$1].index] * companies[$1].shareValue }}
    }

    /// Magister Ludi controls current player and notifies game model when value changes.
    mutating func select(playerIndex: Int) {
        currentPlayerIndex = playerIndex
    }

    /// Heuristic to determine if current player can call the game.
    /// - Requirements: all companies are safe -or- one company has at least `endGameTokenCount` tokens on the board.
    /// - returns: true if current player is leading and can call the game.
    func canPlayerCallGame() -> Bool {
        let maxCompanyTokenCount = activeCompanies.map { $0.tokenCount }.reduce(0) { $0 > $1 ? $0 : $1 }
        let isGameCallable = (!activeCompanies.isEmpty && activeCompanies.filter { $0.isSafe }.count == activeCompanies.count) || maxCompanyTokenCount >= gameConfig.endGameTokenCount
        let leadingPlayerIndex = zip(players.indices.map { $0 }, netWorths).sorted { $0.1 > $1.1 }.first!.0
        return isGameCallable && leadingPlayerIndex == currentPlayerIndex
    }

    /// Provides Magister Ludi with current player's coordinate options.
    /// - returns: possible empty array of playable coordinate options for the current player.
    mutating func playerCoordinateOptions() -> [Coordinate] {

        func isPlayable(coordinate: Coordinate) -> Bool {
            let adjacentCompanyIDs = Array(Set(coordinate.adjacentCoordinates.compactMap { galaxyMap[$0]?.companyID }))
            return adjacentCompanyIDs.count < 2 || adjacentCompanyIDs.count > adjacentCompanyIDs.filter { companies[$0].isSafe }.count
        }

        dealer.filterCoordinates(using: isPlayable)
        var coordinateOptions = players[currentPlayerIndex].coordinateOptions.filter(isPlayable)
        coordinateOptions += dealer.dealCoordinates(count: houseRules.playerCoordinateOptionCount - coordinateOptions.count)
        coordinateOptions = coordinateOptions.sorted { $0.column == $1.column ? $0.row < $1.row : $0.column < $1.column }
        players[currentPlayerIndex].coordinateOptions = coordinateOptions
        return coordinateOptions
    }

    /// Plays a coordinate. Possible results are: new outpost, new company, extended company or merged companies.
    /// - parameter coordinate: Coordinate to play.
    /// - returns: `PlayedCoordinateResult` value that describes the result of playing the coordinate.
    /// - seealso: `PlayedCoordinateResult` enum.
    mutating func play(coordinate: Coordinate) -> [PlayedCoordinateResult] {

        var mergeReports = [MergeReport]()
        var companiesDestroyedByBlackHole = [Int]()

        func convertOutpostToCompany(galaxyMap: GalaxyMap, coordinate: Coordinate, companyID: Int) -> GalaxyMap {
            var result = galaxyMap.clone()
            result[coordinate] = .company(companyID)
            for adjacentCoordinate in (coordinate.adjacentCoordinates.filter { result[$0] == .outpost }) {
                result = convertOutpostToCompany(galaxyMap: result, coordinate: adjacentCoordinate, companyID: companyID)
            }
            return result
        }

        func updateBlackHoles() -> GalaxyMap {
            let newGalaxyMap = galaxyMap.clone()
            blackHoleCoordinates.forEach { blackHoleCoordinate in
                // black hole swallows stars and outposts
                let adjacenctOutposts = blackHoleCoordinate.adjacentCoordinates.filter { galaxyMap[$0] == .star || galaxyMap[$0] == .outpost }
                adjacenctOutposts.forEach {
                    newGalaxyMap[$0] = .destroyed
                }

                // black hole swallows companies
                let adjacentCompanies = Set(blackHoleCoordinate.adjacentCoordinates.compactMap { galaxyMap[$0]?.companyID })
                adjacentCompanies.forEach {
                    var company = companies[$0]
                    company.tokenCount = 0
                    company.shareValue = 0
                    company.isSafe = false
                    company.outstandingShares = 0

                    for index in players.indices {
                        var player = players[index]
                        player.shares[$0] = 0
                        players[index] = player
                    }

                    for coordinate in allCoordinates {
                        if newGalaxyMap[coordinate]?.companyID == $0 {
                            newGalaxyMap[coordinate] = .destroyed
                        }
                    }

                    companiesDestroyedByBlackHole.append($0)
                }
            }
            return newGalaxyMap
        }

        func updateAllCompanyStructs() {
            for index in companies.indices {
                let token = Token.company(index)
                let tokensOnMap = allCoordinates.filter { galaxyMap[$0] == token }
                let adjacentStarCount = Set(tokensOnMap.reduce([Coordinate]()) {$0 + $1.adjacentCoordinates.filter { galaxyMap[$0] == .star }}).count
                let tokenCount = tokensOnMap.count

                companies[index].tokenCount = tokenCount
                companies[index].shareValue = adjacentStarCount * houseRules.shareValueAdjacentStar + tokenCount * houseRules.shareValueAdjacentToken
                companies[index].isSafe     = tokenCount >= gameConfig.safeTokenCount
            }
        }

        func mergeCompanies(survivorID: Int, defunctIDs: [Int]) -> [Int] {
            var remainderSharePlayers = [Int]()
            for defunctID in defunctIDs {

                // Update map
                allCoordinates.filter { galaxyMap[$0] == .company(defunctID) }.forEach { galaxyMap[$0] = .company(survivorID) }

                // Add half the defunct shares to the survivor company, and pay player bonus of % of ownership (10x defunct share value total)
                let defunctOutstandingShares = companies[defunctID].outstandingShares // store here because value will change in loop
                var bonusesPaid = [Int]()
                for index in players.indices {
                    let bonus = defunctOutstandingShares > 0 ?
                                     players[index].shares[defunctID] *
                                     companies[defunctID].shareValue *
                                     houseRules.mergeBonusShareValueMultiple /
                                     defunctOutstandingShares
                                     : 0
                    bonusesPaid.append(bonus)

                    let mergedShareCount = players[index].shares[defunctID]
                    players[index].shares[survivorID] += mergedShareCount / 2
                    companies[survivorID].outstandingShares += mergedShareCount / 2
                    companies[defunctID].outstandingShares -= mergedShareCount
                    if mergedShareCount & 1 != 0 {
                        remainderSharePlayers.append(index) // for odd share count on 2:1 merge, remember the remainder and cash out at end of process
                    }
                    players[index].shares[defunctID] = 0
                    players[index].cash += bonus
                }

                mergeReports.append(MergeReport(mergePlayerIndex: currentPlayerIndex, survivingCompany: companies[survivorID], defunctCompany: companies[defunctID], bonusesPaid: bonusesPaid))
            }
            return remainderSharePlayers
        }

        var result = PlayedCoordinateResult.newOutpost
        let adjacentTokens = coordinate.adjacentCoordinates.compactMap { galaxyMap[$0] }
        let adjacentCompanySet = Array(Set(adjacentTokens.compactMap { $0.companyID })).map { companies[$0] }

        players[currentPlayerIndex].coordinateOptions = players[currentPlayerIndex].coordinateOptions.filter { $0 != coordinate }

        galaxyMap[coordinate] = .outpost  // start with outpost, update as warranted.

        switch adjacentCompanySet.count {
        case 0:
            if (adjacentTokens.first(where: { [Token.star, .outpost].contains($0) }) != nil),
                let newCompanyID = (companies.first(where: { $0.isActive == false })?.index) {
                galaxyMap = convertOutpostToCompany(galaxyMap: galaxyMap, coordinate: coordinate, companyID: newCompanyID)
                galaxyMap = updateBlackHoles()
                updateAllCompanyStructs()
                players[currentPlayerIndex].shares[newCompanyID] = houseRules.founderShareBonus
                companies[newCompanyID].outstandingShares = houseRules.founderShareBonus
                result = .newCompany(companies[newCompanyID])
            }

        case 1:
            galaxyMap = convertOutpostToCompany(galaxyMap: galaxyMap, coordinate: coordinate, companyID: adjacentCompanySet.first!.index)
            galaxyMap = updateBlackHoles()
            updateAllCompanyStructs()
            result = .companyExpanded(adjacentCompanySet.first!)

        case 2, 3, 4:
            var companiesToMerge = zip(
                                       adjacentCompanySet
                                          .map { $0.index },
                                       adjacentCompanySet
                                           // tricky radix-like encoding to sort companies to merge by token count (primary) and alphabetically-earlier company name (secondary)
                                          .map { $0.tokenCount * gameConfig.shippingCompanyCount + (gameConfig.shippingCompanyCount - $0.index) }
                                      )
                                      .sorted { $0.1 > $1.1 }
                                      .map { $0.0 }

            let survivingCompanyID = companiesToMerge.removeFirst()                      // surviving company may or may not be safe
            companiesToMerge = companiesToMerge.filter { companies[$0].isSafe == false } // but all defunct companies by definition are not safe
            let remainderSharePlayers = mergeCompanies(survivorID: survivingCompanyID, defunctIDs: companiesToMerge)

            // update map / companies
            galaxyMap = convertOutpostToCompany(galaxyMap: galaxyMap, coordinate: coordinate, companyID: survivingCompanyID)
            galaxyMap = updateBlackHoles()
            updateAllCompanyStructs()

            for index in remainderSharePlayers {
                players[index].cash += companies[survivingCompanyID].shareValue
            }

            result = .companiesMerged(mergeReports)

        default:break
        }

        return companiesDestroyedByBlackHole.isEmpty ? [result] : [result, .companiesDestroyed(companiesDestroyedByBlackHole)]
    }

    /// Calculates the dividends for the current player and updates player's cash record.
    /// - returns: dividend ammount in dollars
    mutating func calculateDividends() -> Int {
        let dividends = companies.indices.reduce(0) { $0 +  players[currentPlayerIndex].shares[$1] * companies[$1].shareValue } * houseRules.dividendPercent / 100
        players[currentPlayerIndex].cash += dividends
        return dividends
    }

    /// Fulfills a share purchase order for the current player. Share ammounts are updated and players cash is spent.
    /// Note: assumes caller has protected against player's cash amount going negative.
    /// - parameter purchaseOrder: Array of shares to purchase, whose elements correlate to array of active company models.
    mutating func purchaseShares(purchaseOrder: [Int]) {
        for activeCompanyIndex in activeCompanies.indices {
            players[currentPlayerIndex].cash -= purchaseOrder[activeCompanyIndex] * activeCompanies[activeCompanyIndex].shareValue
            players[currentPlayerIndex].shares[activeCompanies[activeCompanyIndex].index] += purchaseOrder[activeCompanyIndex]
            companies[activeCompanies[activeCompanyIndex].index].outstandingShares += purchaseOrder[activeCompanyIndex]
        }
    }

    /// Checks whether there are any playable tiles left. If this is not the case, the game cannot continue and Magister Ludi will call the game.
    /// - returns: true if at least one playable tile is found amonst the player's coordinate options.
    mutating func hasPlayableTiles() -> Bool {
        return players.map { $0.coordinateOptions.count }.reduce(0, +) > 0
    }
}
