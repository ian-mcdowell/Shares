//
//  Item+NSFileProviderItem.swift
//  SharesData
//
//  Created by Ian McDowell on 4/8/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import SharesData
import FileProvider

extension Item: NSFileProviderItem {

    static func fromIdentifier(_ identifier: NSFileProviderItemIdentifier) -> Item? {
        return Item.withID(identifier.rawValue)
    }

    public var itemIdentifier: NSFileProviderItemIdentifier {
        return NSFileProviderItemIdentifier.init(self.id)
    }

    public var parentItemIdentifier: NSFileProviderItemIdentifier {
        return self.parent?.itemIdentifier ?? .rootContainer
    }

    public var filename: String {
        return self.name
    }

    public var typeIdentifier: String {
        return self.UTI
    }

    public var capabilities: NSFileProviderItemCapabilities {
        // TODO
        return .allowsAll
    }

    public var contentModificationDate: Date? {
        return self.lastModified
    }

    public var creationDate: Date? {
        return self.created
    }

    public var childItemCount: NSNumber? {
        if let folder = self as? Folder {
            return folder.contents.count as NSNumber
        }
        return nil
    }

    public var favoriteRank: NSNumber? {
        if let folder = self as? Folder {
            return folder.favoriteDate?.timeIntervalSinceReferenceDate as NSNumber?
        }
        return nil
    }

    public var lastUsedDate: Date? {
        if let file = self as? File {
            return file.lastAccessed
        }
        return nil
    }
}
