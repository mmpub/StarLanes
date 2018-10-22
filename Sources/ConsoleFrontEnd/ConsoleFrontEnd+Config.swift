//
//  ConsoleFrontEnd+Config.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// ConsoleFrontEnd's implementation of the Config component.
extension ConsoleFrontEnd: FrontEndConfig {

    /// Configures the series
    /// - Parameter minPlayerCount: Minimum players allowed in the series.
    /// - Parameter maxPlayerCount: Maximum players allowed in the series.
    /// - Parameter completionHandler: The series game config, house rules and player defs.
    func configureSeries(minPlayerCount: Int, maxPlayerCount: Int, completionHandler: (GameConfig, HouseRules, [VmoPlayerDef]) -> Void) {
        let gameConfig: GameConfig
        let houseRules: HouseRules

        output.write("GAME CONFIGURATION:")
        output.write("  1) CLASSIC GAME  - 5 COMPANIES, 12 X 9 MAP")
        output.write("  2) DELUXE GAME - 10 COMPANIES, 16 X 9 MAP")
        output.write("  3) CUSTOM GAME - CONFIGURE COMPANY, MAP, HOUSE RULES AND MORE.", terminator: "\n\n")
        output.write("SELECT GAME CONFIGURATION (1-3)", terminator: "")

        func readConfigInt(label: String, keyPath: AnyKeyPath) -> Int {
            let basic  = GameConfig.basic[keyPath:keyPath] as? Int ?? 0
            let deluxe = GameConfig.deluxe[keyPath:keyPath] as? Int ?? 0
            let min = GameConfig.min[keyPath:keyPath] as? Int ?? 0
            let max = GameConfig.max[keyPath:keyPath] as? Int ?? 0
            output.write("    ENTER \(label) (BASIC: \(basic); DELUXE: \(deluxe)) (\(min)-\(max))", terminator: "")
            let result = ConsoleInput().readInt(output: output, min: min, max: max)
            output.write()
            return result
        }

        func readRuleInt(label: String, keyPath: AnyKeyPath) -> Int {
            let defaultValue = HouseRules.default[keyPath:keyPath] as? Int ?? 0
            let min          = HouseRules.min[keyPath:keyPath] as? Int ?? 0
            let max          = HouseRules.max[keyPath:keyPath] as? Int ?? 0
            output.write("    ENTER \(label) (DEFAULT: \(defaultValue)) (\(min)-\(max))", terminator: "")
            let result = ConsoleInput().readInt(output: output, min: min, max: max)
            output.write()
            return result
        }

        func readRuleBool(label: String, keyPath: AnyKeyPath) -> Bool {
            output.write("    ENTER \(label) (Y/N)", terminator: "")
            let result = ConsoleInput().readYorN(output: output)
            output.write()
            return result == "Y"
        }

        switch ConsoleInput().readInt(output: output, min: 1, max: 3) {
        case 1:
              gameConfig = GameConfig.basic
              houseRules = HouseRules.default

        case 2:
              gameConfig = GameConfig.deluxe
              houseRules = HouseRules.default

        case 3:
            output.write()
            output.write("CUSTOM GAME CONFIGURATION", terminator: "\n\n")
            let mapColumnCount       = readConfigInt(label: "MAP COLUMN COUNT", keyPath: \GameConfig.mapColumnCount)
            let mapRowCount          = readConfigInt(label: "MAP ROW COUNT", keyPath: \GameConfig.mapRowCount)
            let starCount            = readConfigInt(label: "STAR COUNT", keyPath: \GameConfig.starCount)
            let blackHoleCount       = readConfigInt(label: "BLACK HOLE COUNT", keyPath: \GameConfig.blackHoleCount)
            let shippingCompanyCount = readConfigInt(label: "SHIPPING COMPANIES", keyPath: \GameConfig.shippingCompanyCount)
            let safeTokenCount       = readConfigInt(label: "SAFE COMPANY SIZE", keyPath: \GameConfig.safeTokenCount)
            let endGameTokenCount    = readConfigInt(label: "MINIMUM COMPANY SIZE TO CALL GAME", keyPath: \GameConfig.endGameTokenCount)

            gameConfig = GameConfig(
                             mapColumnCount: mapColumnCount,
                             mapRowCount: mapRowCount,
                             starCount: starCount,
                             blackHoleCount: blackHoleCount,
                             shippingCompanyCount: shippingCompanyCount,
                             safeTokenCount: safeTokenCount,
                             endGameTokenCount: endGameTokenCount
                            )
            output.write()

            output.write("CONFIGURE HOUSE RULES (Y/N)", terminator: "")
            if ConsoleInput().readYorN(output: output) == "Y" {
                output.write()
                output.write("CUSTOM HOUSE RULES CONFIGURATION", terminator: "\n\n")
                let humanInitialCash             = readRuleInt(label: "INITIAL CASH (HUMAN)", keyPath: \HouseRules.humanInitialCash)
                let computerInitialCash          = readRuleInt(label: "INITIAL CASE (COMPUTER)", keyPath: \HouseRules.computerInitialCash)
                let playerCoordinateOptionCount  = readRuleInt(label: "COORDINATE OPTIONS", keyPath: \HouseRules.playerCoordinateOptionCount)
                let founderShareBonus            = readRuleInt(label: "FOUNDER SHARE BONUS", keyPath: \HouseRules.founderShareBonus)
                let shareValueAdjacentStar       = readRuleInt(label: "ADJACENT STAR SHARE VALUE", keyPath: \HouseRules.shareValueAdjacentStar)
                let shareValueAdjacentToken      = readRuleInt(label: "ADJACENT TOKEN SHARE VALUE", keyPath: \HouseRules.shareValueAdjacentToken)
                let dividendPercent              = readRuleInt(label: "DIVIDEND PERCENT", keyPath: \HouseRules.dividendPercent)
                let mergeBonusShareValueMultiple = readRuleInt(label: "MERGE BONUS SHARE VALUE MULTIPLE", keyPath: \HouseRules.mergeBonusShareValueMultiple)
                let isPlayerOrderRandom          = readRuleBool(label: "RANDOMIZE PLAYER ORDER", keyPath: \HouseRules.mergeBonusShareValueMultiple)

                houseRules = HouseRules(
                                 humanInitialCash: humanInitialCash,
                                 computerInitialCash: computerInitialCash,
                                 playerCoordinateOptionCount: playerCoordinateOptionCount,
                                 founderShareBonus: founderShareBonus,
                                 shareValueAdjacentStar: shareValueAdjacentStar,
                                 shareValueAdjacentToken: shareValueAdjacentToken,
                                 dividendPercent: dividendPercent,
                                 mergeBonusShareValueMultiple: mergeBonusShareValueMultiple,
                                 isPlayerOrderRandom: isPlayerOrderRandom
                             )
                output.write()
            } else {
                houseRules = HouseRules.default
            }

        default: return  // shouldn't get here
        }
        output.write()

        var playerDefs = [VmoPlayerDef]()

        func readPlayerNames(isComputer: Bool, min: Int, max: Int) {
            let maxPlayerNameLength = 10
            let type = isComputer ? "COMPUTER" : "HUMAN"

            var playersToInput = min
            if min != max {
                output.write()
                output.write("HOW MANY \(type) PLAYERS (\(min)-\(max))", terminator: "")
                playersToInput = ConsoleInput().readInt(output: output, min: min, max: max)
                output.write()
            }

            while playersToInput > 0 {
                output.write("ENTER PLAYER #\(playerDefs.count+1) (\(type)) NAME: ", terminator: "")
                if let name = readLine() {
                    if name.count > maxPlayerNameLength {
                       output.write()
                       output.write("ERROR: MAXIMUM PLAYER NAME LENGTH IS \(maxPlayerNameLength) CHARACTERS.", terminator: "\n\n")
                    } else if (playerDefs.map { $0.name }.contains(name)) {
                       output.write()
                       output.write("ERROR: PLAYER NAME ALREADY USED.", terminator: "\n\n")
                    } else if !name.isEmpty {
                       playerDefs.append(VmoPlayerDef(name: name, isComputer: isComputer))
                       playersToInput -= 1
                    }
                }
            }
        }

        readPlayerNames(isComputer: true, min: 0, max: maxPlayerCount - 1)
        readPlayerNames(isComputer: false, min: minPlayerCount - (!playerDefs.isEmpty ? 1 : 0), max: maxPlayerCount - playerDefs.count)
        output.write()
        completionHandler(gameConfig, houseRules, playerDefs)
    }

    /// This is for testing or multi-device multiplayer situations where map and player order needs to be deterministic.
    /// - Parameter gameConfig: Series game configuration model.
    /// - Parameter houseRules: Series house rules model.
    /// - Parameter playerDefs: Series player definitions.
    /// - Parameter completionHandler: Tuple: List of coordinates to play, player order; pass nil for defaults.
    func configureGame(gameConfig: GameConfig, houseRules: HouseRules, playerDefs: [VmoPlayerDef], completionHandler: ([Coordinate]?, [Int]?) -> Void) {
        var playerOrder: [Int]? = nil

        if houseRules.isPlayerOrderRandom {
            playerOrder = playerDefs.indices.map { Int($0) }.shuffled()
            output.write("NOW I WILL DECIDE WHO GOES FIRST...")
            sleep(3)
            output.write("HMMMM,... LET ME SEE NOW.")
            sleep(3)
            output.write("OK. I’VE DECIDED....")
            print()
            let position = ["FIRST", "SECOND", "THIRD", "FOURTH"]
            for index in playerDefs.indices {
                output.write("\(playerDefs[playerOrder![index]].name) GOES \(position[index])")
            }
            output.write()
            output.write("PRESS RETURN TO CONTINUE", terminator: "")
            _ = readLine()
        }

        completionHandler(nil, playerOrder) // For regular, single-device game, pass nil to generate random map.
    }
}
