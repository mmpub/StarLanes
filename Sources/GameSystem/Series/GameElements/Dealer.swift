//
//  Dealer.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//
import Foundation

/// A pseudo-entity that manages the unplayed coordinates, dealing out coordinates to play and filtering out unplayable coordinates.
struct Dealer: Codable {

    /// This is the single source of unplayed coordinates in the game model.
    private var unplayedCoordinateStack = [Coordinate]()

    /// Basic initializer.
    /// - parameter coordinateStack: Ordered (shuffled) array of coordinates.
    init(coordinateStack: [Coordinate]) {
        unplayedCoordinateStack = coordinateStack
    }

    /// Deal one playable coordinate.
    /// - returns: Coordinate, or nil if no playable coordinates exists.
    mutating func dealCoordinate() -> Coordinate? {
        return unplayedCoordinateStack.isEmpty ? nil : unplayedCoordinateStack.removeLast()
    }

    /// Deal several playable coordinates.
    /// - parameter count: number of playable coordinates to deal.
    /// - returns: array of playable coordinates; if fewer than `count` playable coordinates exist, all playable coordinates are returned, which could be zero.
    mutating func dealCoordinates(count: Int) -> [Coordinate] {
        return (0 ..< count).compactMap { _ in dealCoordinate() }
    }

    /// Removes playable coordinates from the unplayed stack.
    /// This occurs when a company becomes safe and coordinates that would merge it with another safe company are removed from play.
    /// - parameter using: filter predicate is supplied by game model with logic to protect safe companies.
    mutating func filterCoordinates(using predicate: (Coordinate) -> Bool) {
        unplayedCoordinateStack = unplayedCoordinateStack.filter(predicate)
    }

}
