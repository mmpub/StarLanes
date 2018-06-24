//
//  ConsoleFrontEnd.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// The console front end implementation.
class ConsoleFrontEnd: FrontEnd {
    /// Keyboard input
    let input: Input
    /// Screen output
    let output: Output

    /// `ConsoleFrontEnd` memberwise initializer.
    /// - parameter input: optional override for default console input
    /// - parameter output: optional override for default console output
    init(input: Input? = nil, output: Output? = nil) {
        self.input  = input  ?? ConsoleInput()
        self.output = output ?? ConsoleOutput()
    }
}
