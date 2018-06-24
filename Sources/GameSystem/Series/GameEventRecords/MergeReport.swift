//
//  MergeReport.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// A merge report model used in creating merger announcements. When more than two companies are merged at once, multiple merge reports are generated.
struct MergeReport {
    /// Player who triggered the merge.
    let mergePlayerIndex: Int
    /// Company that survived.
    let survivingCompany: Company
    /// Company that is gone.
    let defunctCompany: Company
    /// Array of bonuses paid used to inform players in announcement.
    let bonusesPaid: [Int]
}
