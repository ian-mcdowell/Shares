//
//  Errors.swift
//  File Provider
//
//  Created by Ian McDowell on 4/8/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import Foundation
import FileProvider

extension NSError {
    static var notAuthenticated: Error {
        return NSError.init(
            domain: NSFileProviderErrorDomain,
            code: NSFileProviderError.notAuthenticated.rawValue,
            userInfo: [
                "NSFileProviderErrorTitle": "Welcome to Shares",
                "NSFileProviderErrorDescription": "Please add an account to get started.",
                "NSFileProviderErrorAction": "Add Account"
            ]
        )
    }
    static var notFound: Error {
        return NSError.init(domain: NSFileProviderErrorDomain, code: NSFileProviderError.noSuchItem.rawValue, userInfo: nil)
    }
    static var serverUnreachable: Error {
        return NSError.init(domain: NSFileProviderErrorDomain, code: NSFileProviderError.serverUnreachable.rawValue, userInfo: nil)
    }
}
