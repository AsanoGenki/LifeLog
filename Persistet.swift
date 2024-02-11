//
//  Persistet2.swift
//  LifeLog
//
//  Created by Genki on 11/1/23.
//

import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer
    init() {
        container = NSPersistentCloudKitContainer(name: "CalendarEvent")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error)")
            }
        })
    }
}
extension PersistenceController {
    var managedObjectContext: NSManagedObjectContext {
        container.viewContext
    }
    var workingContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = managedObjectContext
        return context
    }
}
extension FileManager {
    static let appGroupContainerURL = FileManager.default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.com.DeviceActivityMonitorExtension")!
}
public extension URL {
    static func storeURL(for appGroup: String, database: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Unable to create")
        }
        return fileContainer.appendingPathComponent("\(database).sqlite")
    }
}
