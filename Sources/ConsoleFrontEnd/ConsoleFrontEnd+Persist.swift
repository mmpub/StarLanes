//
//  ConsoleFrontEnd+Persist.swift
//
//  Copyright © 2018 Michael McMahon. All rights reserved worldwide.
//  http://github.com/mmpub/starlanes
//

import Foundation

/// File is stored in users home directory.
private let fileURL = URL(fileURLWithPath: NSString(string: "~/.starlanes").expandingTildeInPath)

/// Front end delegate to store and retrieve a persisted game series.
/// The blob of data is never interpreted by the delegate.
extension ConsoleFrontEnd: FrontEndPersist {

    /// Delegation to retrieve a previously persisted game/series.
    /// - parameter completionHandler: The delegate calls this with the blob of data used to persist the game/series.
    func retrievePersistedSession(completionHandler: (Data?) -> Void) {
        completionHandler(try? Data(contentsOf: fileURL))
    }

    /// Delegation to store a game/series.
    /// - parameter data: Blob of data containing the game/series.
    func persistSession(data: Data) {
        try? data.write(to: fileURL, options: .atomic)
    }
}
