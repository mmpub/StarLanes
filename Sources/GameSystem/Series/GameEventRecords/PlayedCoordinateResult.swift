//
//  PlayedCoordinateResult.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

/// Used by the view model layer (Magister Ludi) to respond to the playing of a coordinate.
enum PlayedCoordinateResult {
    /// Outpost was created by playing a coordinate.
    case newOutpost
    /// Company was created by playing a coordinate.
    case newCompany(Company)
    /// Company was expanded by playing a coordinate.
    case companyExpanded(Company)
    /// Companies were merged by playing a coordinate.
    case companiesMerged([MergeReport])
}
