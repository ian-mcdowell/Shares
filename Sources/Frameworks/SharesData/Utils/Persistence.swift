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

    static let container: NSPersistentContainer = {
        guard
            let url = Bundle.init(for: Persistence.self).url(forResource: "Model", withExtension: "momd"),
            let model = NSManagedObjectModel.init(contentsOf: url)
        else {
            fatalError("Unable to find core data model URL")
        }

        let container = NSPersistentContainer.init(name: "Model", managedObjectModel: model)
        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        })
        return container
    }()

    static func fetch<T>(_ request: NSFetchRequest<T>) throws -> [T] where T : NSFetchRequestResult {
        dispatchPrecondition(condition: .onQueue(.main))
        return try container.viewContext.fetch(request)
    }

    static func count<T>(for request: NSFetchRequest<T>) throws -> Int where T : NSFetchRequestResult {
        dispatchPrecondition(condition: .onQueue(.main))
        return try container.viewContext.count(for: request)
    }
}
