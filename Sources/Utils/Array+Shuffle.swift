//
//  Array+Shuffle.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

import Foundation

extension Array {

    /// Shuffle the elements of an array
    /// - returns: New array containing elements of source array in random order.
    func shuffled() -> [Element] {
        srandom(UInt32(Date().timeIntervalSince1970))
        return sorted { (_, _) in random() & 1 == 0 }
    }
}
