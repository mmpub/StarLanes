//
//  main.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

let magisterLudi = MagisterLudi(frontEnd: ConsoleFrontEnd())

while !magisterLudi.isGameOver {
    magisterLudi.gameLoopIteration()
}
