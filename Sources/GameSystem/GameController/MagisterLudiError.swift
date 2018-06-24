//
//  MagisterLudiError.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// Fatal error description.
public enum MagisterLudiError: Error, Equatable {
    /// Unspecified fatal error occurred at source code location.
    case unspecified(file: String, line: Int)
    /// Series configured with invalid number of players.
    case invalidPlayerCount(min: Int, max: Int, submitted: Int)
    /// Series configured with non-unique player names.
    case nonuniquePlayerNames(submittedNames:[String])
    /// Series configured with empty player names.
    case emptyPlayerNames(submittedNames:[String])
}
