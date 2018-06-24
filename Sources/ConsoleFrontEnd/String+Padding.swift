//
//  String+Padding.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

extension String {

    /// Duplicates a source string and adds trailing padding, if appropriate.
    /// - parameter string: Source string.
    /// - parameter pad: trailing pad count.
    init(_ string: String, pad: Int) {
        let base = string.prefix(pad)
        self =  base + String(repeating: " ", count: pad - base.count)
    }
}
