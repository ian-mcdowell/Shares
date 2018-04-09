//
//  FileProviderExtension+Actions.swift
//  SharesData
//
//  Created by Ian McDowell on 4/8/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import Foundation
import SharesData

extension FileProviderExtension {

    override func createDirectory(withName directoryName: String, inParentItemIdentifier parentItemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {

        switch self.state {
        case .noAccount:
            return completionHandler(nil, NSError.notAuthenticated)
        case .active(let account, _):
            do {
                let folder = try Folder.create(name: directoryName, parent: Item.fromIdentifier(parentItemIdentifier), account: account)
                completionHandler(folder, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
}
