//
//  EndOfGameReason.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// Game can end when lead player calls game, lagging player concedes game or all playable coordinates are exhausted.
public enum EndOfGameReason: Equatable {
    /// Game has ended because lead player called the game.
    case playerCalledGame(String)
    /// Game has ended because lagging player conceded the game.
    case playerConcededGame(String)
    /// Game has ended because there are no more playable coordinates.
    case noMorePlayableCoordinates
}
