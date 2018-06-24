//
//  Instructions.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

let page1 = """
The object of the game is to amass more
money than your fellow players by
establishing vast interstellar shipping
lanes and obtaining stock in the
companies that control these lanes.

During the game, players will be shown
a map of the galaxy, and be given a
choice of five 'space coordinates' which
they may occupy. Occupation of a coordinate
causes one of four things to happen:
"""

let page2 = """
NEW OUTPOST - If the player selects a
coordinate in the middle of nowhere, an
Outpost will be formed. The Outpost will
be marked with a '+'.

NEW SHIPPING COMPANY - If the player
selects a coordinate adjacent to an
Outpost or a Star, a new company will be
formed. The player will receive five
free shares of stock in the new Company.
"""

let page3 = """
MERGER - If the player selects a coordinate
between two different Companies,
the two companies will merge. Any stock
held in the old Company will be converted
into shares in the new Company with a 2:1
old-to-new split.

GROWTH - If the player selects a coordinate
next to an existing Company, the Company
will absorb the coordinate and the value
of it's stock will increase.
"""

let page4 = """
Any Company that occupies at least 11 space
coordinates (15 in Deluxe) is considered Safe
and cannot merge. Any coordinate options for
players that would merge Safe Companies are
removed and replaced with playable coordinates.

After selecting a coordinate, the player
will be allowed to purchase stock in
any of the existing Trading Companies.

The game ends when all legal coordinates have
been played, or if all Companies are safe,
or if any Company occupies at least 41
coordinates (55 in Deluxe), or if a player
is lagging and concedes defeat.
"""

let instructionPages = [page1, page2, page3, page4]
