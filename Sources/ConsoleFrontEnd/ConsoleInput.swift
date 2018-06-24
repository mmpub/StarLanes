//
//  ConsoleInput.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// Console front end implementation of Input protocol
struct ConsoleInput: Input {

    /// Queries a player for a yes or no response. For invalid responses, the user is prompted again.
    /// - parameter output: Output stream to present prompt.
    /// - returns: "Y" or "N"
    func readYorN(output: Output) -> String {
        while true {
            output.write("? ", terminator: "")
            if let str = readLine() {
               if str == "Y" || str == "y" {
                    return "Y"
               } else if str == "N" || str == "n" {
                    return "N"
               }
            }
        }
    }

    /// Queries a player for an integer value. For invalid responses, the user is prompted again.
    /// - parameter output: Output stream to present prompt.
    /// - parameter min: Minimum acceptable input value.
    /// - parameter max: Maximum acceptable input value.
    func readInt(output: Output, min: Int, max: Int) -> Int {
         while true {
            output.write("? ", terminator: "")
            if let str = readLine(),
               let int = Int(str) {
               if int >= min && int <= max {
                   return int
               }
            }
        }
    }
}
