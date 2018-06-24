//
//  VmoPlayerDef.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

import Foundation

/// View model object for player definition. This is invariant throughout the series.
/// An array of these structs is created by the front end and handed to the Magister Ludi 
/// at series configuration to define the participants in the game.
public struct VmoPlayerDef: Codable {
    /// Display name
    public let name: String
    /// If true, Magister Ludi will supply the input for the player during the game.
    public let isComputer: Bool
}
