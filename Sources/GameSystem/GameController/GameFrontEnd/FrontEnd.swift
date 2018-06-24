//
//  FrontEnd.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//
import Foundation

/// Front end is a combination of component protocols.
public protocol FrontEnd: FrontEndConfig, FrontEndPersist, FrontEndInput, FrontEndDisplay {
    /// Console input for the console player(s).
    var input: Input { get }
}

/// Front end delegate to provides series and game configuration.
public protocol FrontEndConfig {
    /// Delegation to acquire series parameters.
    /// - parameter minPlayerCount: Minumum number of players to define.
    /// - parameter maxPlayerCount: Maximum number of players to define.
    /// - parameter completionHandler: Returns game configuration, house rules and an array of player definitions.
    func configureSeries(minPlayerCount: Int, maxPlayerCount: Int, completionHandler: (GameConfig, HouseRules, [VmoPlayerDef]) -> Void)

    /// Delegation to configure order of game coordinates and order of player turns.
    /// - This only functions when order needs to be deterministic (multi-device multi-player, automated testing, etc).
    /// - parameter gameConfig: Game configuration model.
    /// - parameter houseRules: House rules model.
    /// - parameter plaeyerDefs: Array of player definition view models.
    /// - returns: Tuple containing ordered list of coordinates and ordered list of players. If left nil, game model randomizes these arrays internally.
    func configureGame(gameConfig: GameConfig, houseRules: HouseRules, playerDefs: [VmoPlayerDef], completionHandler: ([Coordinate]?, [Int]?) -> Void)
}

/// Front end delegate to store and retrieve a persisted game series.
/// The blob of data is never interpreted by the delegate.
public protocol FrontEndPersist {
    /// Delegation to retrieve a previously persisted game/series.
    /// - parameter completionHandler: The delegate calls this with the blob of data used to persist the game/series.
    func retrievePersistedSession(completionHandler: (Data?) -> Void)

    /// Delegation to store a game/series.
    /// - parameter data: Blob of data containing the game/series.
    func persistSession(data: Data)
}

/// Front end delegates to acquire input responses from players. Each has a completion handler that returns control to Magister Ludi.
public protocol FrontEndInput {

    /// Delegation to query whether the player would like to call the game.
    /// If all companies are safe or one company is large enough, the leading player is afforded the opportunity to
    /// call the game to an end and win. Most of the time, the player will choose to call the game, but in case the
    /// lead player is enjoying the game, they have the option to continue.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter endGameTokenCount: The number of tokens a company must occupy to be large enough to call the game. This value is presented to the user in the query.
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputCallGame(input: Input, endGameTokenCount: Int, completionHandler: (Bool) -> Void)

    /// Delegation to query whether the player would like to concede the game.
    /// This is used when the laggard monitor detects that the player has fallen so far enough behind that ultimate victory is almost impossible.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter playerDef: Player definition view model. Provides player name to the query.
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputConcedeGame(input: Input, playerDef: VmoPlayerDef, completionHandler: (Bool) -> Void)

    /// Delegation to query whether the player would like to play another game in the series.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputPlayAnotherGame(input: Input, completionHandler: (Bool) -> Void)

    /// Delegation to query whether the player (upon launch of Star Lanes) would like to resume the persisted series.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter isResumingGame: Persisted session may be in a game or between games (in a series).
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputResumeSession(input: Input, isResumingGame: Bool, completionHandler: (Bool) -> Void)

    /// Delegation to get player coordinate choice.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter playerDef: Player definition view model. Provides player name to the query.
    /// - parameter coordinateOptions: A set of available coordinates.
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputCoordinate(input: Input, playerDef: VmoPlayerDef, coordinateOptions: [Coordinate], completionHandler: (Coordinate) -> Void)

    /// Delegation to get player stock purchase order for the round.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter activeCompanies: Array of company view models.
    /// - parameter availableCash: Player's cash on hand (this is after dividends are distributed for the turn).
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputPurchaseOrder(input: Input, activeCompanies: [VmoCompany], availableCash: Int, completionHandler: ([Int]) -> Void)
}

/// Front end delegates to present parts of the game to the user.
public protocol FrontEndDisplay {
    /// Delegation to present the title card and instructions.
    /// - parameter title: Title card view model (currently Star Lanes version) to present.
    func display(title vmoTitleCard: VmoTitleCard, completionHandler: () -> Void)

    /// Delegation to present the start of turn message.
    /// - parameter turnStart: Player view model (provides name to display)
    func display(turnStart vmoPlayerDef: VmoPlayerDef)

    /// Delegation to present the galaxy map.
    /// All coordinates are displayed as empty, star, outpost, company token or player coordinate choice index.
    /// - parameter galaxyMap: View model of galaxy map.
    func display(galaxyMap vmoGalaxyMap: VmoGalaxyMap)

    /// Delegation to present list of player ranked in descending order of net worth.
    /// - parameter playerRanking: View model of player ranking.
    func display(playerRanking vmoPlayerRanking: VmoPlayerRanking)

    /// Delegation to present list of active companies.
    /// Company name, price per share and token count are displayed for each.
    /// - parameter activeCompanies: Alphabetical array of company view models.
    func display(activeCompanies vmoCompanies: [VmoCompany])

    /// Delegation to present contents of fatal error.
    /// Note: this only presents a message, it does not terminate the process.
    /// - parameter error: Error model to present
    func display(error: MagisterLudiError)

    /// Delegation to present end of game announcement, including reason game ended and final player ranking.
    /// - parameter endOfGameReason: Reason game ended (player called game, player conceded game or no more playable coordinates).
    /// - parameter vmoPlayerRanking: View model of player ranking.
    func display(endOfGameReason: EndOfGameReason, vmoPlayerRanking: VmoPlayerRanking)

    /// Delegation to display the series leaderboard. Players are listed in descending order of number of games won.
    /// - parameter leaderboard: Array of leaderboard entry view models.
    func display(leaderboard vmoLeaderboardEntries: [VmoLeaderboardEntry])

    /// Delegation to display announcements.
    /// Note: this is a synchronous call. If the announcements are to take time (e.g., animated), the front end can queue these up for
    /// presentation the next time an asynchronous call (i.e., `FrontEndInput`) is made.
    /// - parameter announcements: Array of announcement view models.
    func display(announcements vmoAnnouncements: [VmoAnnouncement])

    /// Delegation to display game configuration and house rules.
    /// These are displayed prior to querying user whether to resume persisted series so the user can
    /// better remember what customizations they have put in.
    /// - parameter gameConfig: Game configuration model.
    /// - parameter houseRules: House rules model.
    func display(gameConfig: GameConfig, houseRules: HouseRules)
}
