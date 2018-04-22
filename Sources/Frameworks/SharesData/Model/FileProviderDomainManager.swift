//
//  FileProviderDomainManager.swift
//  SMB
//
//  Created by Ian McDowell on 7/1/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import FileProvider
import DataUtilities

public extension NSFileProviderDomain {
    static func forAccount(_ account: Account) -> NSFileProviderDomain {
        return NSFileProviderDomain(
            identifier: NSFileProviderDomainIdentifier(rawValue: account.id),
            displayName: displayName(forAccount: account),
            pathRelativeToDocumentStorage: account.id
        )
    }
    
    static func displayName(forAccount account: Account) -> String {
        // If there are multiple accounts with the same description, put the protocol information in the title.
        if !Account.all.filter({ $0.id != account.id }).map({ $0.name }).contains(account.name) {
            return account.name
        }
        return account.name + " (\(account.connectionTypeName))"
    }
}

/// Manager of the File Provider domains for Shares.
/// In this framework so it can be used from both the extensions and app.
/// Don't call these methods from outside the Shares app.
public class FileProviderDomainManager {
    
    private static var isSyncing: Bool = false
    /// Synchronizes the list of SMB accounts with the list of NSFileProviderDomains from the NSFileProviderManager
    public class func syncDomains(_ callback: (() -> Void)? = nil) {
        
        if isSyncing { callback?(); return }
        isSyncing = true
        
        NSFileProviderManager.getDomainsWithCompletionHandler { domains, error in
            if let error = error { print("Error getting file provider domains: \(error.localizedDescription)"); isSyncing = false; callback?(); return; }
            
            let accounts = Account.all
            let accountUUIDs = accounts.map { $0.id }
            
            // Find domains to remove: If the domain's ID is not in the account ID list, remove it.
            let domainsToRemove = domains.filter({ !accountUUIDs.contains($0.identifier.rawValue) })
            
            // Find domains to add: If the account's ID is not in the domain ID list, add a new domain.
            let domainsToAdd = accounts.compactMap({ account -> NSFileProviderDomain? in
                let displayName = NSFileProviderDomain.displayName(forAccount: account)
                if domains.contains(where: { ($0.identifier.rawValue == account.id && $0.displayName == displayName) }) {
                    return nil
                }
                return NSFileProviderDomain.forAccount(account)
            })
            
            if domainsToRemove.isEmpty && domainsToAdd.isEmpty {
                // Nothing to do
                isSyncing = false
                callback?()
                return
            }

            DispatchQueue.main.async {
                // Actually remove the domains
                domainsToRemove.mapAsync({ domain, callback in
                    NSFileProviderManager.remove(domain, completionHandler: { error in
                        print("Removed file provider domain: \(domain.displayName)")
                        DispatchQueue.main.async { callback(error) }
                    })
                }, complete: { (errors: [Error?]) in
                    let errors = errors.compactMap { $0 }
                    if !errors.isEmpty {
                        print("Errors: \(errors)")
                    }
                
                    // Actually add the domains
                    domainsToAdd.mapAsync({ domain, callback in
                        NSFileProviderManager.add(domain, completionHandler: { error in
                            print("Added file provider domain: \(domain.displayName)")
                            DispatchQueue.main.async { callback(error) }
                        })
                    }, complete: { (errors: [Error?]) in
                        let errors = errors.compactMap { $0 }
                        if !errors.isEmpty {
                            print("Errors: \(errors)")
                        }
                    
                        isSyncing = false
                        
                        callback?()
                    })
                })
            }

        }
    }
    
    
}
