//
// LinkdingBookmarkStore.swift
// Created by Christian Wilhelm
//

import CoreData

public class LinkdingBookmarkStore: NSObject, ObservableObject {
    @Published private(set) public var allBookmarks: [LinkdingBookmarkEntity] = []

    private let bookmarkFetchController: NSFetchedResultsController<LinkdingBookmarkEntity>

    override public init() {
        self.bookmarkFetchController = NSFetchedResultsController(
            fetchRequest: LinkdingBookmarkEntity.loadBookmarks(),
            managedObjectContext: LinkdingPersistenceController.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        self.bookmarkFetchController.delegate = self
        do {
            try self.bookmarkFetchController.performFetch()
            self.allBookmarks = self.bookmarkFetchController.fetchedObjects ?? []
        } catch (let error) {
            debugPrint(error)
        }
    }

    public var bookmarks: [LinkdingBookmarkEntity] {
        get {
            return self.allBookmarks
                .filter { $0.locallyDeleted == false }
        }
    }

    public func getByServerId(serverId: Int) -> LinkdingBookmarkEntity? {
        return self.bookmarks
            .filter { $0.serverId == serverId }
            .first
    }
    
    public func getByInternalId(internalId: UUID) -> LinkdingBookmarkEntity? {
        return self.bookmarks
            .filter { $0.internalId == internalId }
            .first
    }
    
    public func getByUrl(url: String) -> LinkdingBookmarkEntity? {
        return self.bookmarks
            .filter { $0.url == url }
            .first
    }

    public func filtered(showArchived: Bool, showUnreadOnly: Bool, filterText: String) -> [LinkdingBookmarkEntity] {
        return self.bookmarks
            .filter {
                if (showArchived == true) {
                    return true
                } else {
                    return $0.isArchived == false
                }
            }
            .filter {
                if (showUnreadOnly) {
                    return $0.unread
                }
                return true
            }
            .filter {
                if (filterText == "") {
                    return true
                }
                let tagFilterText = filterText.first == "#" ?
                    String(filterText.dropFirst()) :
                    filterText
                let tagFound = $0.tagNames.filter {
                        $0.lowercased().starts(with: tagFilterText.lowercased())
                    }.count > 0
                let titleFound = $0.title.lowercased().contains(filterText.lowercased())
                let urlFound = $0.url.lowercased().contains(filterText.lowercased())
                let websiteTitleFound = $0.websiteTitle != nil ? $0.websiteTitle!.lowercased().contains(filterText.lowercased()) : false
                return tagFound || titleFound || urlFound || websiteTitleFound
            }
    }

    public var untagged: [LinkdingBookmarkEntity] {
        get {
            return self.bookmarks
                .filter { $0.tagNames.count == 0 }
        }
    }

    public var notArchivedOnly: [LinkdingBookmarkEntity] {
        get {
            return self.bookmarks
                .filter { $0.isArchived == false }
        }
    }

    public var onlyNewBookmarks: [LinkdingBookmarkEntity] {
        get {
            return self.bookmarks
                .filter { $0.serverId == 0 }
        }
    }

    public var onlyModifiedBookmarks: [LinkdingBookmarkEntity] {
        get {
            return self.bookmarks
                .filter { $0.locallyModified == true }
        }
    }

    public var onlyLocallyDeletedBookmarks: [LinkdingBookmarkEntity] {
        get {
            return self.allBookmarks
                .filter { $0.locallyDeleted == true }
        }
    }
}

extension LinkdingBookmarkStore: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let bookmarkEntities = controller.fetchedObjects as? [LinkdingBookmarkEntity] else {
            return
        }

        self.allBookmarks = bookmarkEntities
    }
}
