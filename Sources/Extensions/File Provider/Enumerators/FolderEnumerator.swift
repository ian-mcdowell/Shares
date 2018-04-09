//
//  FileProviderEnumerator.swift
//  FileProvider
//
//  Created by Ian McDowell on 4/6/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import FileProvider
import SharesData

class FolderEnumerator: NSObject, NSFileProviderEnumerator {

    let folder: Folder?
    
    init(folder: Folder?) {
        self.folder = folder
        super.init()
    }

    func invalidate() {
        // TODO: perform invalidation of server connection if necessary
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        /* TODO:
         - inspect the page to determine whether this is an initial or a follow-up request
         
         If this is an enumerator for a directory, the root container or all directories:
         - perform a server request to fetch directory contents
         If this is an enumerator for the active set:
         - perform a server request to update your local database
         - fetch the active set from your local database
         
         - inform the observer about the items returned by the server (possibly multiple times)
         - inform the observer that you are finished with this page
         */

        observer.didEnumerate(Item.itemsWithParent(self.folder))
        observer.finishEnumerating(upTo: nil)
    }

}


