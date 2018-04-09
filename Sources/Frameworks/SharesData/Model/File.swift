//
//  File.swift
//  SharesData
//
//  Created by Ian McDowell on 4/8/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import Foundation
import CoreData

@objc(File)
public class File: Item {

    private static func fetchRequest() -> NSFetchRequest<File> {
        return NSFetchRequest<File>(entityName: "File")
    }

    @NSManaged public var size: Int64
    @NSManaged public var lastAccessed: Date?

    public static var recents: [File] {
        let request: NSFetchRequest<File> = File.fetchRequest()
        request.predicate = NSPredicate.init(format: "lastAccessed != nil")
        request.sortDescriptors = [
            NSSortDescriptor.init(key: #keyPath(File.lastAccessed), ascending: true)
        ]
        request.fetchLimit = 10
        do {
            return try Persistence.fetch(request)
        } catch {
            fatalError("Unable to fetch recents")
        }
    }
}
