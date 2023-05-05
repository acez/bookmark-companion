//
// CoreDataMigration1To2Test.swift
// Created by Christian Wilhelm
//

import XCTest
@testable import Application

import CoreData

final class CoreDataMigration1To2Test: XCTestCase {
    private func cleanStore(context: NSManagedObjectContext, fileUrl: URL) throws {
        for store in context.persistentStoreCoordinator!.persistentStores {
            try context.persistentStoreCoordinator!.remove(store)
        }
        
        try? FileManager.default.removeItem(at: fileUrl)
    }
    
    private var dataDirectory: URL {
        get {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    }
    
    private func loadManagedObjectModel(name: String) -> NSManagedObjectModel {
        let sourceModelUrl = Bundle(for: BookmarkCompanionPersistentContainer.self)
            .url(forResource: "LinkdingModel", withExtension: "momd")!
            .appendingPathComponent(name)
            .appendingPathExtension("mom")
        return NSManagedObjectModel(contentsOf: sourceModelUrl)!
    }
    
    private func loadObjectContext(sqliteUrl: URL, mom: NSManagedObjectModel) throws -> NSManagedObjectContext {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteUrl)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
    
    func testMigration() throws {
        let sourceSqliteUrl = self.dataDirectory.appendingPathComponent("SourceLinkdingModel.sqlite")
        let targetSqliteUrl = self.dataDirectory.appendingPathComponent("TargetLinkdingModel.sqlite")
        
        let sourceMom = self.loadManagedObjectModel(name: "LinkdingModel")
        let sourceContext = try self.loadObjectContext(sqliteUrl: sourceSqliteUrl, mom: sourceMom)
        
        XCTAssertFalse(NSEntityDescription.entity(forEntityName: "Bookmark", in: sourceContext)!.propertiesByName.keys.contains("internalId"))
        XCTAssertFalse(NSEntityDescription.entity(forEntityName: "Tag", in: sourceContext)!.propertiesByName.keys.contains("internalId"))
        
        let sourceBookmark = NSEntityDescription.insertNewObject(forEntityName: "Bookmark", into: sourceContext)
        sourceBookmark.setValue(100, forKey: "serverId")
        sourceBookmark.setValue("https://www.github.com", forKey: "url")
        sourceBookmark.setValue("GitHub", forKey: "title")
        sourceBookmark.setValue("", forKey: "urlDescription")
        sourceBookmark.setValue("", forKey: "websiteTitle")
        sourceBookmark.setValue("", forKey: "websiteDescription")
        sourceBookmark.setValue(false, forKey: "isArchived")
        sourceBookmark.setValue(false, forKey: "unread")
        sourceBookmark.setValue(false, forKey: "shared")
        sourceBookmark.setValue(false, forKey: "locallyDeleted")
        sourceBookmark.setValue(false, forKey: "locallyModified")
        sourceBookmark.setValue(NSSet(), forKey: "relTags")
        let sourceTag = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: sourceContext)
        sourceTag.setValue(200, forKey: "serverId")
        sourceTag.setValue("dummy-tag", forKey: "name")
        sourceTag.setValue(NSSet(), forKey: "relBookmarks")
        try sourceContext.save()
        
        let targetMom = self.loadManagedObjectModel(name: "LinkdingModel 2")
        let mapping = NSMappingModel(from: nil, forSourceModel: sourceMom, destinationModel: targetMom)
        let manager = NSMigrationManager(sourceModel: sourceMom, destinationModel: targetMom)
        
        try manager.migrateStore(
            from: sourceSqliteUrl,
            sourceType: NSSQLiteStoreType,
            options: nil,
            with: mapping,
            toDestinationURL: targetSqliteUrl,
            destinationType: NSSQLiteStoreType,
            destinationOptions: nil
        )
        
        let targetContext = try self.loadObjectContext(sqliteUrl: targetSqliteUrl, mom: targetMom)
        
        XCTAssertTrue(NSEntityDescription.entity(forEntityName: "Bookmark", in: targetContext)!.propertiesByName.keys.contains("internalId"))
        XCTAssertTrue(NSEntityDescription.entity(forEntityName: "Tag", in: targetContext)!.propertiesByName.keys.contains("internalId"))
        
        let bookmarks = try targetContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Bookmark"))
        XCTAssertEqual(bookmarks.count, 1)
        let testBookmark = bookmarks.first! as! NSManagedObject
        XCTAssertNotNil(testBookmark.value(forKey: "internalId"))
        XCTAssertEqual(testBookmark.value(forKey: "serverId") as! Int, 100)
        XCTAssertEqual(testBookmark.value(forKey: "url") as! String, "https://www.github.com")
        XCTAssertEqual(testBookmark.value(forKey: "title") as! String, "GitHub")
        
        let tags = try targetContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "Tag"))
        XCTAssertEqual(tags.count, 1)
        let testTag = tags.first! as! NSManagedObject
        XCTAssertNotNil(testTag.value(forKey: "internalId"))
        XCTAssertEqual(testTag.value(forKey: "serverId") as! Int, 200)
        XCTAssertEqual(testTag.value(forKey: "name") as! String, "dummy-tag")

        try? self.cleanStore(context: sourceContext, fileUrl: sourceSqliteUrl)
        try? self.cleanStore(context: targetContext, fileUrl: targetSqliteUrl)
    }
    
}
