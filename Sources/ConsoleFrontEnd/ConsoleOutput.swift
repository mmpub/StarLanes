//
//  ConsoleOutput.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// Abstraction to output strings to the front end.
class ConsoleOutput: Output {

    /// Writes a newline character to the output.
    func write() {
        print()
    }

    /// Writes a string to the output with a newline appended.
    func write(_ string: String) {
        print(string)
    }

    /// Writes a string to the output with terminator appended.
    func write(_ string: String, terminator: String) {
        print(string, terminator: terminator)
    }
}
