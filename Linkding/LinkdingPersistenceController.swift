//
// LinkdingPersistenceController.swift
// Created by Christian Wilhelm
//

import Foundation
import CoreData

class BookmarkCompanionPersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.bookmarkcompanion")!
    }
}

public struct LinkdingPersistenceController {
    public static let shared = LinkdingPersistenceController()

    private let container: NSPersistentContainer

    private let observer: PersistenceHistoryObserver

    public var viewContext: NSManagedObjectContext {
        get {
            return self.container.viewContext
        }
    }

    public func refreshExternalChanges() {
        self.viewContext.stalenessInterval = 0
        self.viewContext.refreshAllObjects()
        self.viewContext.stalenessInterval = -1
    }

    public func setViewContextData(name: String, author: String) {
        self.viewContext.name = "view_context"
        self.viewContext.transactionAuthor = "main_app"
    }

    public init(inMemory: Bool = false) {
        container = BookmarkCompanionPersistentContainer(name: "LinkdingModel")

        // Activate History Tracking
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError()
        }
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        container.persistentStoreDescriptions = [description]

        try? container.viewContext.setQueryGenerationFrom(.current)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        self.observer = PersistenceHistoryObserver(container: container)
        self.observer.start()

        container.viewContext.automaticallyMergesChangesFromParent = true

        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.propagatesDeletesAtEndOfEvent = true

    }
}
