//
//  FileProviderExtension.swift
//  FileProvider
//
//  Created by Ian McDowell on 4/6/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import FileProvider
import SharesData

enum ExtensionState {
    case noAccount
    case active(account: Account, manager: NSFileProviderManager)

    var isNoAccount: Bool {
        switch self {
        case .noAccount:
            return true
        default:
            return false
        }
    }
}

class FileProviderExtension: NSFileProviderExtension {

    private var currentState: ExtensionState = .noAccount
    var state: ExtensionState {
        switch currentState {
        case .active:
            break
        default:
            let state: ExtensionState
            // If we have a domain and the account is found, make sure the state is active.
            if
                let domain = self.domain,
                let manager = NSFileProviderManager.init(for: domain),
                let account = Account.withID(domain.identifier.rawValue)
            {
                state = .active(account: account, manager: manager)
            } else {
                state = .noAccount
            }

            self.currentState = state
        }
        return currentState
    }
    
    var fileManager = FileManager()
    
    override init() {
        super.init()

        FileProviderDomainManager.syncDomains()
    }
    
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        // resolve the given identifier to a record in the model
        guard
            let item = Item.fromIdentifier(identifier)
        else {
            throw NSError.notFound
        }
        return item
    }
    
    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        // resolve the given identifier to a file on disk
        guard let item = try? item(for: identifier) else {
            return nil
        }
        
        // in this implementation, all paths are structured as <base storage directory>/<item identifier>/<item file name>
        let manager = NSFileProviderManager.default
        let perItemDirectory = manager.documentStorageURL.appendingPathComponent(identifier.rawValue, isDirectory: true)
        try! fileManager.createDirectory(at: perItemDirectory, withIntermediateDirectories: true, attributes: nil)
        
        return perItemDirectory.appendingPathComponent(item.filename, isDirectory:false)
    }
    
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        // resolve the given URL to a persistent identifier using a database
        let pathComponents = url.pathComponents
        
        // exploit the fact that the path structure has been defined as
        // <base storage directory>/<item identifier>/<item file name> above
        assert(pathComponents.count > 2)
        
        return NSFileProviderItemIdentifier(pathComponents[pathComponents.count - 2])
    }
    
    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        guard let identifier = persistentIdentifierForItem(at: url) else {
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }

        do {
            let fileProviderItem = try item(for: identifier)
            let placeholderURL = NSFileProviderManager.placeholderURL(for: url)
            try NSFileProviderManager.writePlaceholder(at: placeholderURL,withMetadata: fileProviderItem)
            completionHandler(nil)
        } catch let error {
            completionHandler(error)
        }
    }

    override func startProvidingItem(at url: URL, completionHandler: @escaping ((_ error: Error?) -> Void)) {
        // Should ensure that the actual file is in the position returned by URLForItemWithIdentifier:, then call the completion handler
        
        /* TODO:
         This is one of the main entry points of the file provider. We need to check whether the file already exists on disk,
         whether we know of a more recent version of the file, and implement a policy for these cases. Pseudocode:
         
         if !fileOnDisk {
             downloadRemoteFile()
             callCompletion(downloadErrorOrNil)
         } else if fileIsCurrent {
             callCompletion(nil)
         } else {
             if localFileHasChanges {
                 // in this case, a version of the file is on disk, but we know of a more recent version
                 // we need to implement a strategy to resolve this conflict
                 moveLocalFileAside()
                 scheduleUploadOfLocalFile()
                 downloadRemoteFile()
                 callCompletion(downloadErrorOrNil)
             } else {
                 downloadRemoteFile()
                 callCompletion(downloadErrorOrNil)
             }
         }
         */
        
        completionHandler(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
    }
    
    
    override func itemChanged(at url: URL) {
        // Called at some point after the file has changed; the provider may then trigger an upload
        
        /* TODO:
         - mark file at <url> as needing an update in the model
         - if there are existing NSURLSessionTasks uploading this file, cancel them
         - create a fresh background NSURLSessionTask and schedule it to upload the current modifications
         - register the NSURLSessionTask with NSFileProviderManager to provide progress updates
         */
    }
    
    override func stopProvidingItem(at url: URL) {
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        // Care should be taken that the corresponding placeholder file stays behind after the content file has been deleted.
        
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        
        // TODO: look up whether the file has local changes
        let fileHasLocalChanges = false
        
        if !fileHasLocalChanges {
            // remove the existing file to free up space
            do {
                _ = try FileManager.default.removeItem(at: url)
            } catch {
                // Handle error
            }
            
            // write out a placeholder to facilitate future property lookups
            self.providePlaceholder(at: url, completionHandler: { error in
                // TODO: handle any error, do any necessary cleanup
            })
        }
    }
    
    // MARK: - Actions
    
    /* TODO: implement the actions for items here
     each of the actions follows the same pattern:
     - make a note of the change in the local model
     - schedule a server request as a background task to inform the server of the change
     - call the completion block with the modified item in its post-modification state
     */
    
    // MARK: - Enumeration
    
    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        switch containerItemIdentifier {
        case .workingSet:
            return WorkingSetEnumerator()
        case .rootContainer:
            if state.isNoAccount { throw NSError.notAuthenticated }
            return FolderEnumerator(folder: nil)
        default:
            if state.isNoAccount { throw NSError.notAuthenticated }
            
            // resolve the given identifier to a file on disk
            guard let item = try? item(for: containerItemIdentifier) else {
                throw NSError.notFound
            }
            if let file = item as? File {
                return FileEnumerator.init(file: file)
            } else if let folder = item as? Folder {
                return FolderEnumerator.init(folder: folder)
            }
            throw NSError.notFound
        }

    }
    
}
