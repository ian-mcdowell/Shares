//
//  Item.swift
//  SharesData
//
//  Created by Ian McDowell on 4/8/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import Foundation
import CoreData
import MobileCoreServices

@objc(Item)
public class Item: NSManagedObject {

    internal static func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public private(set) var id: String

    @NSManaged public var created: Date?
    @NSManaged public var lastModified: Date?
    @NSManaged public var name: String
    
    @NSManaged public var parent: Item?
    @NSManaged public var account: Account

    public var isFavorite: Bool {
        if let folder = self as? Folder {
            return folder.favoriteDate != nil
        }
        return false
    }

    public var UTI: String {
        if self is File {
            let defaultValue = kUTTypeData as String
            let ext = (self.name as NSString).pathExtension
            if ext.isEmpty {
                return defaultValue
            }
            let type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeUnretainedValue() as String?
            return type ?? defaultValue
        } else if self is Folder {
            return kUTTypeFolder as String
        } else {
            assertionFailure("Invalid item type. Neither file nor folder")
            return kUTTypeData as String
        }
    }

    public static func itemsWithParent(_ parent: Item?) -> [Item] {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        if let parent = parent {
            request.predicate = NSPredicate.init(format: "parent == %@", parent)
        } else {
            request.predicate = NSPredicate.init(format: "parent == nil")
        }
        request.sortDescriptors = [
            NSSortDescriptor.init(key: #keyPath(Item.name), ascending: true)
        ]
        do {
            return try Persistence.fetch(request)
        } catch {
            fatalError("Unable to fetch accounts")
        }
    }

    public static func withID(_ id: String) -> Item? {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate.init(format: "id == %@", id)
        request.fetchLimit = 1
        do {
            return try Persistence.fetch(request).first
        } catch {
            fatalError("Unable to fetch item with id \(id)")
        }
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        self.id = UUID().uuidString
    }
}
