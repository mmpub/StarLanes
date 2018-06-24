//
//  VmoCompany.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// View model object for a company.
public struct VmoCompany {
    /// Display name
    public let name: String
    /// First letter of display name
    public let monogram: String
    /// Current share price
    public let shareValue: Int
    /// Number of tokens on map
    public let size: Int
    /// Sum of shares held by players
    public let outstandingShares: Int
    /// If true, can only be the surviving company in a merger. Otherwise, can go defunct in a merger.
    public let isSafe: Bool
}

extension VmoCompany {
    /// Basic initializer.
    /// - parameter company: Company model to transform into this view model.
    init(company: Company) {
        let names = [
                    "ALTAIR STARWAYS",
                    "BETELGEUSE, LTD.",
                    "CAPELLA FREIGHT CO",
                    "DENEBOLA SHIPPERS",
                    "ERIDANI EXPEDITERS",
                    "FOMALHAUT FEDERATED",
                    "GALAXY BROS. DIRECT",
                    "HAMALI HAULERS",
                    "INTERSTELLAR LINES",
                    "JETSON EXPRESS INC."
                ]

        name              = names[company.index]
        monogram          = String(name.prefix(1))
        shareValue        = company.shareValue
        size              = company.tokenCount
        outstandingShares = company.outstandingShares
        isSafe            = company.isSafe
    }
}
