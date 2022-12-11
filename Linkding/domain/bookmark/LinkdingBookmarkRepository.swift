//
// LinkdingBookmarkRepository.swift
// Created by Christian Wilhelm
//

import Foundation

public class LinkdingBookmarkRepository {
    private let bookmarkStore: LinkdingBookmarkStore
    private let tagStore: LinkdingTagStore

    public init(bookmarkStore: LinkdingBookmarkStore, tagStore: LinkdingTagStore) {
        self.bookmarkStore = bookmarkStore
        self.tagStore = tagStore
    }

    private func getOrCreateByServerId(serverId: Int, url: String, title: String, urlDescription: String) -> LinkdingBookmarkEntity {
        guard let bookmark = self.bookmarkStore.getByServerId(serverId: serverId) else {
            return LinkdingBookmarkEntity.createBookmark(moc: LinkdingPersistenceController.shared.viewContext, url: url, title: title, urlDescription: urlDescription)
        }
        return bookmark
    }

    @MainActor
    public func deleteBookmark(bookmark: LinkdingBookmarkEntity) {
        LinkdingPersistenceController.shared.viewContext.delete(bookmark)
        try? LinkdingPersistenceController.shared.viewContext.save()
    }

    @MainActor
    public func deleteBookmarkByServerId(serverId: Int) {
        guard let bookmark = self.bookmarkStore.getByServerId(serverId: serverId) else {
            return
        }

        LinkdingPersistenceController.shared.viewContext.delete(bookmark)
        try? LinkdingPersistenceController.shared.viewContext.save()
    }

    @MainActor
    public func updateExistingBookmarkFromServer(
        bookmark: LinkdingBookmarkEntity,
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
    ) {
        bookmark.updateServerData(
            serverId: serverId,
            url: url,
            title: title,
            urlDescription: urlDescription,
            websiteTitle: websiteTitle,
            websiteDescription: websiteDescription,
            isArchived: isArchived,
            unread: unread,
            shared: shared,
            dateAdded: dateAdded,
            dateModified: dateModified,
            tags: self.tagStore.getByNameList(names: tags)
        )
        try? LinkdingPersistenceController.shared.viewContext.save()
    }

    @MainActor
    public func createOrUpdateBookmarkFromServer(
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
    ) {
        let bookmark = self.getOrCreateByServerId(serverId: serverId, url: url, title: title, urlDescription: urlDescription)
        let needsUpdate = bookmark.needsUpdate(serverId: bookmark.serverId, url: url, title: title, urlDescription: urlDescription, websiteTitle: websiteTitle, websiteDescription: websiteDescription, isArchived: isArchived, unread: unread, shared: shared, dateAdded: dateAdded, dateModified: dateModified, tags: tags)
        if (needsUpdate) {
            bookmark.updateServerData(
                serverId: serverId,
                url: url,
                title: title,
                urlDescription: urlDescription,
                websiteTitle: websiteTitle,
                websiteDescription: websiteDescription,
                isArchived: isArchived,
                unread: unread,
                shared: shared,
                dateAdded: dateAdded,
                dateModified: dateModified,
                tags: self.tagStore.getByNameList(names: tags)
            )
            try? LinkdingPersistenceController.shared.viewContext.save()
        }
    }

    @MainActor
    public func createNewBookmark(url: String, title: String, description: String, isArchived: Bool, unread: Bool, shared: Bool, tags: [String]) -> LinkdingBookmarkEntity {
        let bookmark = LinkdingBookmarkEntity.createBookmark(moc: LinkdingPersistenceController.shared.viewContext, url: url, title: title, urlDescription: description)
        bookmark.updateFlags(isArchived: isArchived, unread: unread, shared: shared)
        bookmark.updateTags(tags: self.tagStore.getByNameList(names: tags))

        try? LinkdingPersistenceController.shared.viewContext.save()

        return bookmark
    }

    @MainActor
    public func updateBookmark(bookmark: LinkdingBookmarkEntity, url: String, title: String, description: String, isArchived: Bool, unread: Bool, shared: Bool, tags: [String]) -> LinkdingBookmarkEntity {
        bookmark.updateData(url: url, title: title, urlDescription: description)
        bookmark.updateFlags(isArchived: isArchived, unread: unread, shared: shared)
        bookmark.updateTags(tags: self.tagStore.getByNameList(names: tags))

        try? LinkdingPersistenceController.shared.viewContext.save()

        return bookmark
    }

    @MainActor
    public func markAsDeleted(bookmark: LinkdingBookmarkEntity) {
        if (bookmark.localOnly) {
            LinkdingPersistenceController.shared.viewContext.delete(bookmark)
        } else {
            bookmark.markAsDeleted()
        }

        try? LinkdingPersistenceController.shared.viewContext.save()
    }
}
