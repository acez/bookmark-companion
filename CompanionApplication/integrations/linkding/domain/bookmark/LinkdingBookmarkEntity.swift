//
// LinkdingBookmarkEntity.swift
// Created by Christian Wilhelm
//

import Foundation
import CoreData

@objc(LinkdingBookmarkEntity)
public class LinkdingBookmarkEntity: NSManagedObject, Identifiable {
    @NSManaged private(set) public var serverId: Int // is: id in API
    @NSManaged private(set) public var internalId: UUID
    @NSManaged private(set) public var url: String
    @NSManaged private(set) public var title: String
    @NSManaged private(set) public var urlDescription: String // is: description in API
    @NSManaged private(set) public var websiteTitle: String?
    @NSManaged private(set) public var websiteDescription: String?
    @NSManaged private(set) public var isArchived: Bool
    @NSManaged private(set) public var unread: Bool
    @NSManaged private(set) public var shared: Bool
    @NSManaged private(set) public var dateAdded: Date?
    @NSManaged private(set) public var dateModified: Date?
    @NSManaged private(set) public var locallyDeleted: Bool
    @NSManaged private(set) public var locallyModified: Bool
    @NSManaged private(set) public var relTags: NSSet

    public var tagNames: [String] {
        get {
            self.relTags.map { tag in
                let castedTag = tag as! LinkdingTagEntity
                return castedTag.name
            }
        }
    }
    
    public var tags: [Tag<UUID>] {
        get {
            self.relTags.map { tag in
                let castedTag = tag as! LinkdingTagEntity
                return Tag(id: castedTag.internalId, name: castedTag.name)
            }
        }
    }
    
    public var tagEntities: [LinkdingTagEntity] {
        get {
            self.relTags.map { $0 as! LinkdingTagEntity }
        }
    }

    public func needsUpdate(
        serverId: Int,
        url: String,
        title: String,
        urlDescription: String,
        websiteTitle: String?,
        websiteDescription: String?,
        isArchived: Bool,
        unread: Bool,
        shared: Bool,
        dateAdded: Date?,
        dateModified: Date?,
        tags: [String]
    ) -> Bool {
        return self.serverId != serverId ||
            self.url != url ||
            self.title != title ||
            self.urlDescription != urlDescription ||
            self.websiteTitle != websiteTitle ||
            self.websiteDescription != websiteDescription ||
            self.isArchived != isArchived ||
            self.unread != unread ||
            self.shared != shared ||
            self.dateAdded != dateAdded ||
            self.dateModified != dateModified ||
            Set(self.tagNames) != Set(tags)
    }

    public func updateServerData(
        serverId: Int,
        url: String,
        title: String,
        urlDescription: String,
        websiteTitle: String?,
        websiteDescription: String?,
        isArchived: Bool,
        unread: Bool,
        shared: Bool,
        dateAdded: Date?,
        dateModified: Date?,
        tags: [LinkdingTagEntity]
    ) {
        self.serverId = serverId
        self.url = url
        self.title = title
        self.urlDescription = urlDescription
        self.websiteTitle = websiteTitle
        self.websiteDescription = websiteDescription
        self.isArchived = isArchived
        self.unread = unread
        self.shared = shared
        self.dateAdded = dateAdded
        self.dateModified = dateModified
        self.relTags = NSSet(array: tags)
        self.locallyDeleted = false
        self.locallyModified = false
    }

    public func updateFlags(isArchived: Bool, unread: Bool, shared: Bool) {
        self.isArchived = isArchived
        self.unread = unread
        self.shared = shared
        self.locallyModified = true
    }

    public func updateTags(tags: [LinkdingTagEntity]) {
        self.relTags = NSSet(array: tags)
        self.locallyModified = true
    }

    public func updateData(url: String, title: String, urlDescription: String) {
        self.url = url
        self.title = title
        self.urlDescription = urlDescription
        self.locallyModified = true
    }

    public func markAsDeleted() {
        self.locallyDeleted = true
    }

    public func markAsOk() {
        self.locallyModified = false
    }

    public var localOnly: Bool {
        get {
            return self.serverId == 0
        }
    }

    public var displayTitle: String {
        get {
            if (self.title != "") {
                return self.title
            }

            if (self.websiteTitle != nil && self.websiteTitle != "") {
                return self.websiteTitle!
            }

            return self.url
        }
    }
    
    public var displayDescription: String {
        get {
            if (self.urlDescription != "") {
                return self.urlDescription
            }
            
            if (self.websiteDescription != nil && self.websiteDescription != "") {
                return self.websiteDescription!
            }
            
            return ""
        }
    }
}

extension LinkdingBookmarkEntity {
    public static func createBookmark(
        moc: NSManagedObjectContext,
        url: String,
        title: String,
        urlDescription: String
    ) -> LinkdingBookmarkEntity {
        let entity = LinkdingBookmarkEntity.init(context: moc)

        entity.serverId = 0
        entity.internalId = UUID()
        entity.url = url
        entity.title = title
        entity.urlDescription = urlDescription
        entity.isArchived = false
        entity.unread = true
        entity.shared = false
        entity.locallyDeleted = false
        entity.locallyModified = false

        return entity
    }
}

extension LinkdingBookmarkEntity {
    public class func loadBookmarks() -> NSFetchRequest<LinkdingBookmarkEntity> {
        let request = NSFetchRequest<LinkdingBookmarkEntity>(entityName: "Bookmark")

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \LinkdingBookmarkEntity.url, ascending: true),
            NSSortDescriptor(keyPath: \LinkdingBookmarkEntity.title, ascending: true)
        ]
        request.relationshipKeyPathsForPrefetching = ["relTags"]

        return request
    }
}
