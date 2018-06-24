//
//  Output.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// Abstraction to output strings to the front end.
public protocol Output {
    /// Writes a newline character to the output.
    func write()
    /// Writes a string to the output with a newline appended.
    func write(_ string: String)
    /// Writes a string to the output with terminator appended.
    func write(_ string: String, terminator: String)
}
