//
//  Folder.swift
//  SharesData
//
//  Created by Ian McDowell on 4/8/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import Foundation
import CoreData

@objc(Folder)
public class Folder: Item {

    private static func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var favoriteDate: Date?

    public var contentsCount: Int {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate.init(format: "parent == %@", self)
        do {
            return try Persistence.count(for: request)
        } catch {
            fatalError("Unable to fetch accounts")
        }
    }

    public var contents: [Item] {
        return Item.itemsWithParent(self)
    }

    public static func create(
        name: String,
        parent: Item?,
        account: Account
    ) throws -> Folder {
        let context = Persistence.container.viewContext
        let folder = Folder(context: context)

        folder.name = name
        folder.parent = parent
        folder.account = account

        try context.save()
        return folder
    }

    public static var favorites: [Folder] {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        request.predicate = NSPredicate.init(format: "favoriteDate != nil")
        request.sortDescriptors = [
            NSSortDescriptor.init(key: #keyPath(Folder.favoriteDate), ascending: true)
        ]
        do {
            return try Persistence.fetch(request)
        } catch {
            fatalError("Unable to fetch favorites")
        }
    }
}
