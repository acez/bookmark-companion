//
// LinkdingTagEntity.swift
// Created by Christian Wilhelm
//

import Foundation
import CoreData

@objc(LinkdingTagEntity)
public class LinkdingTagEntity: NSManagedObject, Identifiable {
    @NSManaged private(set) public var serverId: Int // is: id in API
    @NSManaged private(set) public var internalId: UUID
    @NSManaged private(set) public var name: String
    @NSManaged private(set) public var dateAdded: Date?
    @NSManaged private(set) public var relBookmarks: NSSet

    public var bookmarks: [LinkdingBookmarkEntity] {
        get {
            self.relBookmarks.map({ bookmark in
                bookmark as! LinkdingBookmarkEntity
            })
        }
    }

    public func updateServerData(serverId: Int, name: String, dateAdded: Date?) {
        self.serverId = serverId
        self.name = name
        self.dateAdded = dateAdded
    }
}

extension LinkdingTagEntity {
    public static func createTag(
        moc: NSManagedObjectContext,
        name: String
    ) -> LinkdingTagEntity {
        let entity = LinkdingTagEntity.init(context: moc)

        entity.serverId = 0
        entity.internalId = UUID()
        entity.name = name

        return entity
    }
}

extension LinkdingTagEntity {
    public class func loadTags() -> NSFetchRequest<LinkdingTagEntity> {
        let request = NSFetchRequest<LinkdingTagEntity>(entityName: "Tag")

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \LinkdingTagEntity.name, ascending: true)
        ]
        request.relationshipKeyPathsForPrefetching = ["relBookmarks"]

        return request
    }
}
