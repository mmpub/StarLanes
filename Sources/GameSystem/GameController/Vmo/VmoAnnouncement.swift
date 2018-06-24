//
//  VmoAnnouncement.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// View model object for an announcement.
public enum VmoAnnouncement {
    /// Announcement that a company has been founded.
    case newCompany(VmoCompany, founder: String)
    /// Announcement of a merger between two companys. When more than two companies merge, multiple announcements are made.
    case merger(byPlayer: String, survivingCompany: VmoCompany, defunctCompany: VmoCompany, bonus: Int)
    /// Announcement of dividends.
    case dividends(Int)
    /// Announcement that a company has grown large enough to become safe from merger.
    case safeCompany(VmoCompany)
}

extension VmoAnnouncement {
    /// Informs the front end that this announcement is special (i.e., not a regular dividend report).
    var isSpecial: Bool {
        if case .dividends = self {
            return false
        }
        return true
    }
}
