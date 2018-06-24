//
//  MagisterLudiState.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// Current state of Magister Ludi state machine (current state of the game experienc)
enum MagisterLudiState: Equatable {
    /// Front end is displaying title card and instructions
    case displayTitle
    /// After title card, game attempts to retrieve persisted game/series.
    /// If there is one, the player has the option to continue the game/series or start a new series.
    case retrievePersistedSession
    /// If the player is starting a new series, they must configure it first in this state.
    case configureSeries
    /// Series is starting its next game.
    case startGame
        /// Game is starting its next round (where each player takes a turn).
        case startRound
            /// Round is starting its next turn.
            case startTurn
                /// If a player can call or concede the game, make the offer in this state.
                case checkEarlyGameEnd
                /// Player is presented the galaxy map and requested to select a playabale coordinate.
                case selectCoordinate
                /// Dividends are calculated and presented to the player.
                case calculateDividends
                /// Player is offered shares in all companies they can afford.
                case purchaseShares
            /// Round is ending its turn (selecting the next player)
            case endTurn
        /// All players have played a turn, time to end the round.
        case endRound
    /// Game has ended.
    case endGame(EndOfGameReason)
    /// Any time the Magister Ludi is waiting on asynchronous input from the front end, this state is used.
    /// The state machine will be changed by a completion handler closure called by the front end.
    case awaitingInput
    /// During development, anomalous states trigger a fatal error. This states are easy to avoid and released games should never need this.
    case error(MagisterLudiError)
    /// After a game, player has decided not to continue the series (for now), which is the end state of this state machine.
    case gameOver
}
