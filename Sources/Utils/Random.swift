//
//  Random.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

#if canImport(Darwin)
import Darwin

/// Basic random number generator.
func random() -> UInt {
    return UInt(arc4random())
}
#endif
