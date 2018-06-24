//
//  PersistedSessionContainer.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//
import Foundation

/// The information that is persisted.
struct PersistedSessionContainer: Codable {
    /// StarLanes version
    let version: String
    /// Series configuration
    let series: Series
    /// If persisted between games, this will be nil. Otherwise, persisted at the end of a player's turn.
    let game: Game?
}

extension PersistedSessionContainer {

    /// Takes a blob of data previously created by this container, and re-populate 
    /// - parameter data: Blob of data
    init?(data: Data) {
        if let persistentSessionContainer = try? JSONDecoder().decode(PersistedSessionContainer.self, from: data) {
            self = persistentSessionContainer
        } else {
            return nil
        }
    }

    /// Creates a blob of data from this container.
    var data: Data? {
        return try? JSONEncoder().encode(self)
    }
}
