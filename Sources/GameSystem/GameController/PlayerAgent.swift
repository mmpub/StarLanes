//
//  PlayerAgent.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// View Model representation of a player in a game.
class PlayerAgent {
    /// Player name from the series player def.
    let name: String
    /// Input source
    let input: Input
    /// Announcements queued up for the next front end update.
    private var pendingAnnouncements: [VmoAnnouncement]

    // Basic initializer.
    // - parameter name: Player name
    // - parameter input: Player input source.
    init(name: String, input: Input) {
        self.name = name
        self.input = input
        pendingAnnouncements = [VmoAnnouncement]()
    }

    /// Enqueues announcement to be presented in the next console front end update.
    /// - parameter announcement: the announcement
    func announce(_ announcement: VmoAnnouncement) {
        pendingAnnouncements.append(announcement)
    }

    /// Dequeues all pending announcements for the front end and resets the announcements.
    func publishAnnouncements() -> [VmoAnnouncement] {
        let result = pendingAnnouncements
        pendingAnnouncements = [VmoAnnouncement]()
        return result
    }

    /// Resets the announcements for this player. Used to refresh the player agent at the start of a game.
    func resetAnnouncements() {
        pendingAnnouncements = [VmoAnnouncement]()
    }
}

extension Array where Element: PlayerAgent {

    /// Resets the announcements for all players. Used to refresh the player agent at the start of a game.
    func resetAnnouncements() {
        for playerAgent in self {
            playerAgent.resetAnnouncements()
        }
    }

    /// Enqueues a announcement to be broadcast to all players. Basically, every announcement except dividends (which are individualized) can be broadcast.
    func announce(_ announcement: VmoAnnouncement) {
        for playerAgent in self {
            playerAgent.announce(announcement)
        }
    }
}
