//
//  Persistence.swift
//  SharesData
//
//  Created by Ian McDowell on 4/8/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import Foundation
import CoreData

internal class Persistence {

    private static let appGroupID = "group.net.ianmcdowell.shares"

    public static let containerURL: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)!

    static let container: NSPersistentContainer = {
        guard
            let url = Bundle.init(for: Persistence.self).url(forResource: "Model", withExtension: "momd"),
            let model = NSManagedObjectModel.init(contentsOf: url)
        else {
            fatalError("Unable to find core data model URL")
        }

        let container = NSPersistentContainer.init(name: "Model", managedObjectModel: model)
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription.init(url: Persistence.containerURL.appendingPathComponent("storage.sqlite"))
        ]
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        })
        return container
    }()

    private static let context: NSManagedObjectContext = {
        return container.newBackgroundContext()
    }()

    static func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult {
//        dispatchPrecondition(condition: .onQueue(.main))
        return try context.fetch(request)
    }

    static func count<T>(for request: NSFetchRequest<T>) throws -> Int where T : NSFetchRequestResult {
//        dispatchPrecondition(condition: .onQueue(.main))
        return try context.count(for: request)
    }
}
