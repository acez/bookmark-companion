//
// LinkdingTagStore.swift
// Created by Christian Wilhelm
//

import CoreData

public class LinkdingTagStore: NSObject, ObservableObject {
    @Published private(set) public var tags: [LinkdingTagEntity] = []

    private let tagFetchController: NSFetchedResultsController<LinkdingTagEntity>

    override public init() {
        self.tagFetchController = NSFetchedResultsController(
            fetchRequest: LinkdingTagEntity.loadTags(),
            managedObjectContext: LinkdingPersistenceController.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        self.tagFetchController.delegate = self
        do {
            try self.tagFetchController.performFetch()
            self.tags = self.tagFetchController.fetchedObjects ?? []
        } catch (let error) {
            debugPrint(error)
        }
    }

    public func getByServerId(serverId: Int) -> LinkdingTagEntity? {
        return self.tags
            .filter { $0.serverId == serverId }
            .first
    }

    public func getByInternalIdList(uuids: [UUID]) -> [LinkdingTagEntity] {
        return self.tags
            .filter { uuids.contains($0.internalId) }
    }

    public func getByNameList(names: [String]) -> [LinkdingTagEntity] {
        return self.tags
            .filter { names.contains($0.name) }
    }

    public var usedTags: [LinkdingTagEntity] {
        get {
            self.tags
                .filter { $0.bookmarks.count > 0 }
        }
    }

    public func filteredTags(nameFilter: String, onlyUsed: Bool) -> [LinkdingTagEntity] {
        let tags = onlyUsed ? self.usedTags : self.tags
        
        if (nameFilter == "") {
            return tags
        }

        return tags.filter { $0.name.lowercased().contains(nameFilter.lowercased()) }
    }
    
    public var onlyLocalTags: [LinkdingTagEntity] {
        get {
            self.tags.filter { $0.serverId == 0 }
        }
    }
}

extension LinkdingTagStore: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tagEntities = controller.fetchedObjects as? [LinkdingTagEntity] else {
            return
        }

        self.tags = tagEntities
    }
}

