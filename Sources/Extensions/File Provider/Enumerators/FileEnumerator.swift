//
//  FileEnumerator.swift
//  File Provider
//
//  Created by Ian McDowell on 4/9/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import FileProvider
import SharesData

class FileEnumerator: NSObject, NSFileProviderEnumerator {

    let file: File

    init(file: File) {
        self.file = file
        super.init()
    }

    func invalidate() {
        // TODO: perform invalidation of server connection if necessary
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        observer.finishEnumerating(upTo: nil)
    }
}
