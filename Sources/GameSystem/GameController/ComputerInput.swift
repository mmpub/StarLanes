//
//  ComputerInput.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// The computer player's input. This implements the A.I. for the game
class ComputerInput: Input {
    /// A queued response of how many shares to purchase for all available companies this turn.
    var intInput = [Int]()

    /// Computer player's response to a yes/no question.
    /// - parameters:
    ///   - output: The output stream to print the response.
    /// - returns: "Y" always
    func readYorN(output: Output) -> String {
        let result = "Y"
        output.write("\(result)")
        return result
    }

    /// Computer player's response to a quantity question.
    /// - parameters:
    ///   - output: The output stream to print the response.
    /// - returns: an integer response to the game's quantity query.
    func readInt(output: Output, min: Int, max: Int, defaultValue: Int? = nil) -> Int {
        let result = !intInput.isEmpty ? intInput.removeFirst() : min
        output.write("\(result)")
        return result
    }

    /// AI function to select of coordinate from a set of options.
    ///
    /// The algorithm is brute-force: try all options and choose the one that
    /// delivers the best net worth. Note: this approach requires `gameModel`
    /// to be a struct instead of a class.
    ///
    /// The selection is queued up in the `intInput` array and returned to
    /// the game the next time `readInt` is invoked.
    ///
    /// - parameters:
    ///   - playerIndex: Player's index in `gameModel` players array.
    ///   - coordinateOptions: Available coordinate options.
    ///   - gameModel: Current state of the game.
    func decideCoordinateSelection(playerIndex: Int, coordinateOptions: [Coordinate], gameModel: GameModel) {
        let netWorths = coordinateOptions.map { coordinate -> Double in
            var testGameModel = gameModel.clone()
            _ = testGameModel.play(coordinate: coordinate)
            _ = testGameModel.calculateDividends()
            let netWorths = testGameModel.netWorths.map { Double($0) }
            return netWorths[playerIndex] / netWorths.reduce(0.0, +)
        }
        let option = zip(coordinateOptions.indices.map { Int($0) }, netWorths).sorted { $0.1 > $1.1 }.first!.0
        intInput = [option + 1]
    }

    /// AI function to evaluate all active companies and decide which shares
    /// to purchase and how many.
    ///
    /// The approach is to select one company and purchase as many
    /// shares as possible with cash on hand.
    ///
    /// The purchase amounts are queued up in the `intInput` array and returned to
    /// the game during subsequent `readInt` invocations.
    ///
    /// - parameters:
    ///   - playerIndex: Player's index in `gameModel` players array.
    ///   - gameModel: Current state of the game.
    func decideSharePurchase(playerIndex: Int, gameModel: GameModel) {

        /// Decides which (if any) company to purchase shares in.
        /// - parameters:
        ///   - shares: array of shares held by player in active companies.
        ///   - activeCompanies: array of active companies.
        /// - returns:
        func selectCompany(shares: [Int], activeCompanies: [Company]) -> Int? {
            if activeCompanies.isEmpty {
                return nil
            }

            let firstCompany             = activeCompanies.first!
            var cheapestCompany          = firstCompany
            var greatestOwnershipCompany = firstCompany
            var greatestOwnershipPct     =  0.0

            for (company, shares) in zip(activeCompanies, shares) {
                if company.shareValue < cheapestCompany.shareValue {
                    cheapestCompany = company
                }
                let ownershipPct =  Double(shares) / Double(company.outstandingShares)
                if ownershipPct > greatestOwnershipPct {
                    greatestOwnershipCompany = company
                    greatestOwnershipPct = ownershipPct
                }
            }

            // AI decision-making heuristics:
            //   - which company do I have the greatest lead in?
            //   - is the cheapest company that less than 2/3 the price of this company?
            //     -> yes, invest in cheapest else invest in greatest lead.
            return cheapestCompany.shareValue < greatestOwnershipCompany.shareValue * 2 / 3 ? cheapestCompany.index : greatestOwnershipCompany.index
        }

        let activeCompanies = gameModel.activeCompanies
        let player = gameModel.players[playerIndex]
        var cash = player.cash
        let selectedCompanyIndex = selectCompany(shares: gameModel.companies.filter { $0.isActive }.map {player.shares[$0.index]}, activeCompanies: activeCompanies)
        var result = [Int]()
        for index in activeCompanies.indices where cash >= activeCompanies[index].shareValue {
            let amount = activeCompanies[index].index == selectedCompanyIndex ? cash / activeCompanies[index].shareValue : 0
            result.append(amount)
            cash -= amount * activeCompanies[index].shareValue
        }
        intInput = result
    }
}
