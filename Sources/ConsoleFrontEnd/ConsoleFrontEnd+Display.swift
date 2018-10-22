//
//  ConsoleFrontEnd+Display.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// All the presentation logic for the console output.
extension ConsoleFrontEnd: FrontEndDisplay {

    /// Displays the title card and optionally game instructions.
    /// - parameter title: Title card view model, passed in from Magister Ludi.
    /// - parameter completionHandler: Called when user is ready to continue.
    func display(title vmoTitleCard: VmoTitleCard, completionHandler: () -> Void) {
        let SPACER = "     "
        output.write(SPACER + "* S T A R  L A N E S *")
        output.write()
        output.write(SPACER + "      THE GAME")
        output.write(SPACER + "         OF")
        output.write(SPACER + "INTERSTELLAR TRADING")
        output.write()
        output.write(SPACER + "    VERSION \(vmoTitleCard.version)")
        output.write()
        output.write()
        output.write("INSTRUCTIONS (Y/N)", terminator: "")

        if ConsoleInput().readYorN(output: output) == "Y" {
            for page in instructionPages {
                output.write("", terminator: "\n\n\n")
                output.write(page.uppercased(), terminator: "\n\n\n")
                output.write("PRESS RETURN TO CONTINUE", terminator: "")
                _ = readLine()
            }
            output.write("", terminator: "\n\n")
        }
        output.write()
        completionHandler()
    }

    /// Displays the announcement that the next player is now starting their turn.
    /// - parameter turnStart: Current player definition.
    func display(turnStart vmoPlayerDef: VmoPlayerDef) {
        output.write("<-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=->", terminator: "\n\n")
        output.write("   \(vmoPlayerDef.name) STARTS TURN . . .", terminator: "\n\n")
    }

    /// Displays a list of players, ranked by descending net worth.
    /// - parameter vmoPlayerRanking: Player ranking view model.
    func display(playerRanking vmoPlayerRanking: VmoPlayerRanking) {
        var haveSafe = false

        // Print table header
        output.write("RANK   PLAYER    NET WORTH    ", terminator: "")
        for company in vmoPlayerRanking.activeCompanies {
            if company.isSafe {
                output.write(String("\(company.monogram)*", pad: 8), terminator: "")
                haveSafe = true
            } else {
                output.write(String(company.monogram, pad: 8), terminator: "")
            }
        }
        output.write()

        // Print underscores to table header
        output.write("----   ------    ---------   ", terminator: "")
        vmoPlayerRanking.activeCompanies.forEach { _ in
            output.write("------  ", terminator: "")
        }
        output.write()

        // Print table rows
        for (rank, player) in zip(vmoPlayerRanking.rankedPlayers.indices, vmoPlayerRanking.rankedPlayers) {
            output.write(" #\(String(String(rank+1), pad: 5))\(String(player.name, pad: 10))\(String(String(money: player.netWorth), pad: 13))", terminator: "")
            if !vmoPlayerRanking.activeCompanies.isEmpty {
                for share in player.activeCompanyShares {
                    output.write("\(String(String(share), pad: 8))", terminator: "")
                }
            }
            output.write()
        }
        output.write()

        // Print footer
        if haveSafe {
            output.write("* = safe", terminator: "\n\n")
        }
    }

    /// Displays the map of the galaxy, with stars, outposts and company tokens.
    /// - parameter vmoGalaxyMap: Galaxy map view model.
    func display(galaxyMap vmoGalaxyMap: VmoGalaxyMap) {
        let SPACER = "    "

        // Display title bar
        let title = "MAP OF THE GALAXY"
        output.write(String(repeating: " ", count: SPACER.count * 2 - 1 + ((vmoGalaxyMap.columnCount * 5) - title.count)/2) + title)
        output.write(String(repeating: " ", count: SPACER.count * 2 - 1) + String(repeating: "*", count: vmoGalaxyMap.columnCount * 5))

        // Display column headers
        let letterA = UInt8(65)
        output.write((0 ..< vmoGalaxyMap.columnCount).reduce(SPACER + " ") { $0 + SPACER + String(UnicodeScalar(letterA + UInt8($1))) })

        // Display row headers and map grid
        (0 ..< vmoGalaxyMap.rowCount).forEach { row in
            let line = (0 ..< vmoGalaxyMap.columnCount).reduce(SPACER + "\(row+1)") { $0 + SPACER + vmoGalaxyMap.map[$1][row] }
            output.write(line, terminator: "\n\n")
        }

        // Add vertical whitespace
        output.write()
    }

    /// Displays a list of the active companies, with company name, share price and coordinate count for each.
    /// - parameter activeCompanies: An alphabetized array of active company view models.
    func display(activeCompanies vmoCompanies: [VmoCompany]) {
        if !vmoCompanies.isEmpty {
            output.write("COMPANY             PRICE/SHARE  SIZE")
            output.write("------------------- -----------  ----")
            for company in vmoCompanies {
                output.write("\(String(company.name, pad: 20))\(String(String(money: company.shareValue), pad: 14))\(String("\(company.size)", pad: 8))")
            }
            output.write()
        }
    }

    /// Displays a fatal error message. Does not terminate the app.
    /// - All conditions that trigger this are easy to guard against; this should never be seen in released game.
    /// - parameter error: Error object from Magister Ludi.
    func display(error: MagisterLudiError) {
        output.write()
        output.write(" *** FATAL ERROR *** ")
        switch error {
        case let .unspecified(file, line):
            output.write("Unspecified: file:\(file) line:\(line)")

        case let .invalidPlayerCount(min, max, submitted):
            output.write("Invalid player count submitted:\(submitted), must be between \(min) and \(max).")

        case let .nonuniquePlayerNames(submittedNames):
            output.write("All player names should be unique. Submitted names:\(submittedNames.joined(separator: ", "))")

        case let .emptyPlayerNames(submittedNames):
            output.write("All player names must be non-empty. Submitted names:\(submittedNames.joined(separator: ", "))")
        }
    }

    /// Displays an announcement that the game has ended, and why.
    /// - parameter endOfGameReason: Reason why game ended. (player called game, player conceded game or no more playable coordinates).
    /// - parameter vmoPlayerRanking: Player ranking view model to display final player ranking.
    func display(endOfGameReason reason: EndOfGameReason, vmoPlayerRanking: VmoPlayerRanking) {
        let banner: String
        switch reason {
        case let .playerCalledGame(playerName):
            banner = "\n***************************************************\n\(playerName) HAS ANNOUNCED THE END OF THE GAME\n***************************************************\n"
        case let .playerConcededGame(playerName):
            banner = "\n***************************************************\n\(playerName) HAS CONCEDED DEFEAT\n***************************************************\n"
        case .noMorePlayableCoordinates:
            banner = "ALL PLAYABLE COORDINATES HAVE BEEN USED. GAME IS OVER!"
        }
        output.write(banner, terminator: "\n\n")
        output.write("* * * FINAL SCOREBOARD * * *", terminator: "\n\n")
        display(playerRanking: vmoPlayerRanking)
    }

    /// Displays a leaderboard between games in a series.
    /// - parameter vmoLeaderboardEntries: Array of leaderboard entry view models.
    func display(leaderboard vmoLeaderboardEntries: [VmoLeaderboardEntry]) {
        output.write("* * * LEADERBOARD * * *", terminator: "\n\n")
        output.write("RANK PLAYER                GAMES WON")
        output.write("---- --------------------  ---------")
        var rank = 1
        for entry in vmoLeaderboardEntries {
            output.write("\(String("\(rank)", pad: 6))\(String(entry.name, pad: 22))\(String("\(entry.gamesWon)", pad: 8))")
            rank += 1
        }
        output.write()
    }

    /// Displays a list of announcements.
    /// - parameter announcements: Array of announcement view models.
    func display(announcements vmoAnnouncements: [VmoAnnouncement]) {
        let specialAnnouncementCount = vmoAnnouncements.filter { $0.isSpecial }.count
        if specialAnnouncementCount > 0 {
            output.write("* * * SPECIAL ANNOUNCEMENT\(specialAnnouncementCount > 1 ? "S" : "") * * *", terminator: "\n\n")
        }

        for announcement in vmoAnnouncements {
            switch announcement {
            case let .newCompany(company, founder):
                output.write("A NEW SHIPPING COMPANY HAS BEEN FORMED BY \(founder)")
                output.write("IT'S NAME IS \(company.name)")

            case let .merger(byPlayer, survivingCompany, defunctCompany, bonus):
                output.write("\(defunctCompany.name) HAS BEEN MERGED INTO \(survivingCompany.name) BY \(byPlayer)")
                output.write("YOU GET A BONUS OF \(String(money: bonus))")

            case let .dividends(dividends):
                output.write("PERIODIC DIVIDENDS OF \(String(money: dividends)) HAVE BEEN PAID TO YOU.")

            case let .safeCompany(company):
                output.write("\(company.name) IS NOW SAFE. IT CANNOT BE TAKEN OVER IN A MERGE.")

            case let .destroyedCompany(company):
                output.write("\(company.name) HAS BEEN DESTROYED BY A BLACK HOLE !")
            }
            output.write("")
        }
    }

    /// Displays the game configuration and house rules. This is presented after the title card when asking
    /// the user whether to a persisted series.
    /// - parameter gameConfig: Game configuration model.
    /// - parameter houseRules: House rules model.
    func display(gameConfig: GameConfig, houseRules: HouseRules) {
        if gameConfig != GameConfig.basic && gameConfig != GameConfig.deluxe {
            output.write("GAME CONFIGURATION")
            output.write("------------------")
            output.write("MAP COLUMN COUNT: \(gameConfig.mapColumnCount)")
            output.write("MAP ROW COUNT: \(gameConfig.mapRowCount)")
            output.write("STAR COUNT: \(gameConfig.starCount)")
            output.write("BLACK HOLE COUNT: \(gameConfig.blackHoleCount)")
            output.write("SHIPPING COMPANIES: \(gameConfig.shippingCompanyCount)")
            output.write("SAFE COMPANY SIZE: \(gameConfig.safeTokenCount)")
            output.write("MINIMUM COMPANY SIZE TO CALL GAME: \(gameConfig.endGameTokenCount)")
            output.write("")
            if houseRules != HouseRules.default {
                output.write("HOUSE RULES")
                output.write("-----------")
                output.write("INITIAL CASH (HUMAN): \(houseRules.humanInitialCash)")
                output.write("INITIAL CASE (COMPUTER): \(houseRules.computerInitialCash)")
                output.write("COORDINATE OPTIONS: \(houseRules.playerCoordinateOptionCount)")
                output.write("FOUNDER SHARE BONUS: \(houseRules.founderShareBonus)")
                output.write("ADJACENT STAR SHARE VALUE: \(houseRules.shareValueAdjacentStar)")
                output.write("ADJACENT TOKEN SHARE VALUE: \(houseRules.shareValueAdjacentToken)")
                output.write("DIVIDEND PERCENT: \(houseRules.dividendPercent)")
                output.write("MERGE BONUS SHARE VALUE MULTIPLE: \(houseRules.mergeBonusShareValueMultiple)")
                output.write("")
            }
        }
    }
}
