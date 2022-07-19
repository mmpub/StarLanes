//
//  ConsoleFrontEnd+Input.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// Front end delegates to acquire input responses from players. Each has a completion handler that returns control to Magister Ludi.
extension ConsoleFrontEnd: FrontEndInput {

    /// Delegation to query whether the player would like to call the game.
    /// If all companies are safe or one company is large enough, the leading player is afforded the opportunity to
    /// call the game to an end and win. Most of the time, the player will choose to call the game, but in case the
    /// lead player is enjoying the game, they have the option to continue.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter endGameTokenCount: The number of tokens a company must occupy to be large enough to call the game. This value is presented to the user in the query.
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputCallGame(input: Input, endGameTokenCount: Int, completionHandler: (Bool) -> Void) {
        output.write("=================================================================")
        output.write("ALL COMPANIES ARE SAFE OR ONE COMPANY HAS AT LEAST \(endGameTokenCount) TOKENS,")
        output.write("MEANING THE GAME CAN END, IF YOU CHOOSE.")
        output.write("=================================================================")
        output.write("END GAME (Y/N) ", terminator: "")
        completionHandler(input.readYorN(output: output) == "Y")
        output.write()
    }

    /// Delegation to query whether the player would like to concede the game.
    /// This is used when the laggard monitor detects that the player has fallen so far enough behind that ultimate victory is almost impossible.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter playerDef: Player definition view model. Provides player name to the query.
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputConcedeGame(input: Input, playerDef: VmoPlayerDef, completionHandler: (Bool) -> Void) {
        output.write("====================================")
        output.write("\(playerDef.name), YOU'RE LAGGING. YOU CAN NOW CHOOSE")
        output.write("TO RESIGN AND CONCEDE DEFEAT.")
        output.write("====================================")
        output.write("END GAME (Y/N) ", terminator: "")
        completionHandler(input.readYorN(output: output) == "Y")
        output.write()
    }

    /// Delegation to query whether the player would like to play another game in the series.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputPlayAnotherGame(input: Input, completionHandler: (Bool) -> Void) {
        output.write("PLAY ANOTHER GAME IN THIS SERIES (Y/N) ", terminator: "")
        completionHandler(input.readYorN(output: output) == "Y")
        output.write()
    }

    /// Delegation to query whether the player (upon launch of Star Lanes) would like to resume the persisted series.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter isResumingGame: Persisted session may be in a game or between games (in a series).
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputResumeSession(input: Input, isResumingGame: Bool, completionHandler: (Bool) -> Void) {
        output.write("RESUME \(isResumingGame ? "GAME" : "SERIES") (Y/N) ", terminator: "")
        completionHandler(input.readYorN(output: output) == "Y")
        output.write()
    }

    /// Delegation to get player coordinate choice.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter playerDef: Player definition view model. Provides player name to the query.
    /// - parameter coordinateOptions: A set of available coordinates.
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputCoordinate(input: Input, playerDef: VmoPlayerDef, coordinateOptions: [Coordinate], completionHandler: (Coordinate) -> Void) {
        output.write("\(playerDef.name), YOUR CURRENT MOVES ARE:")
        output.write("\t", terminator: "")
        for index in coordinateOptions.indices {
            output.write("\(index+1): \(coordinateOptions[index])", terminator: "    ")
        }
        output.write("", terminator: "\n\n")
        output.write("WHAT IS YOUR SELECTION ", terminator: "")
        completionHandler(coordinateOptions[input.readInt(output: output, min: 1, max: coordinateOptions.count, defaultValue: nil)-1])
        output.write()
    }

    /// Delegation to get player stock purchase order for the round.
    /// - parameter input: The abstract input interface (human or computer) that provides the input.
    /// - parameter activeCompanies: Array of company view models.
    /// - parameter availableCash: Player's cash on hand (this is after dividends are distributed for the turn).
    /// - parameter completionHandler: This is called to return control to Magister Ludi.
    func inputPurchaseOrder(input: Input, activeCompanies: [VmoCompany], availableCash: Int, completionHandler: ([Int]) -> Void) {
        var cash = availableCash
        var result = Array(repeating: 0, count: activeCompanies.count)
        for index in activeCompanies.indices where cash >= activeCompanies[index].shareValue {
            let maxAmount = cash / activeCompanies[index].shareValue
            output.write("YOUR CURRENT CASH = \(String(money: cash))")
            output.write("BUY HOW MANY SHARES OF \(activeCompanies[index].name) AT \(String(money: activeCompanies[index].shareValue)) (UP TO \(maxAmount))")
            result[index] = input.readInt(output: output, min: 0, max: maxAmount, defaultValue: nil)
            output.write()
            cash -= result[index] * activeCompanies[index].shareValue
        }
        completionHandler(result)
    }
}
