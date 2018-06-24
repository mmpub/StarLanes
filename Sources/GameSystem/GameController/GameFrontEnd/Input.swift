//
//  Input.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// Abstraction to read input from human or computer players.
public protocol Input {

    /// Queries a player for a yes or no response. For invalid responses, the user is prompted again.
    /// - parameter output: Output stream to present prompt.
    /// - returns: "Y" or "N"
    func readYorN(output: Output) -> String

    /// Queries a player for an integer value. For invalid responses, the user is prompted again.
    /// - parameter output: Output stream to present prompt.
    /// - parameter min: Minimum acceptable input value.
    /// - parameter max: Maximum acceptable input value.
    func readInt(output: Output, min: Int, max: Int) -> Int
}
