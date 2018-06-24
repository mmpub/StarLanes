//
//  String+Money.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

extension String {

    /// Creates an American-style money representation with a dollar sign and thousands separator.
    /// Assumption in the 1970's was that US currency would become the intergalactic standard.
    /// - parameter money: amount in dollars
    init(money: Int) {
        if money == 0 {
            self = "$0"
        } else {
            var value = money >= 1_000_000_000 ? money + 500_000 : money
            var segments = [String]()
            while value > 0 {
                let segment = value % 1000
                value /= 1000
                let segmentString: String
                if value == 0 {
                    segmentString = "\(segment)"
                } else if segment < 10 {
                    segmentString = "00\(segment)"
                } else if segment < 100 {
                    segmentString = "0\(segment)"
                } else {
                    segmentString = "\(segment)"
                }
                segments.append(segmentString)
            }
            if money >= 1_000_000_000 {
                let segs = Array(segments.reversed())
                self = "$\(segs[0]).\(segs[1])B"
            } else {
                self = "$\(segments.reversed().joined(separator: ","))"
            }
        }
    }
}
