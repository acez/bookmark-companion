//
// LinkdingTagRepository.swift
// Created by Christian Wilhelm
//

import Foundation

public class LinkdingTagRepository {
    private let tagStore: LinkdingTagStore

    public init(tagStore: LinkdingTagStore) {
        self.tagStore = tagStore
    }
    
    public func createTag(tag: TagModel) -> LinkdingTagEntity {
        let entity = self.getOrCreateEntity(serverId: tag.serverId)
        entity.updateServerData(serverId: tag.serverId ?? 0, name: tag.name, dateAdded: tag.dateAdded)
        try? LinkdingPersistenceController.shared.viewContext.save()
        return entity
    }
    
    public func updateTag(entity: LinkdingTagEntity, updateData: TagModel) {
        LinkdingPersistenceController.shared.viewContext.perform {
            entity.updateServerData(serverId: updateData.serverId ?? 0, name: updateData.name, dateAdded: updateData.dateAdded)
            try? LinkdingPersistenceController.shared.viewContext.save()
        }
    }

    public func batchApplyChanges(models: [TagModel]) {
        LinkdingPersistenceController.shared.viewContext.performAndWait {
            models.forEach {
                let entity = self.getOrCreateEntity(serverId: $0.serverId)
                entity.updateServerData(serverId: $0.serverId ?? 0, name: $0.name, dateAdded: $0.dateAdded)
            }
            try? LinkdingPersistenceController.shared.viewContext.save()
        }
    }
    
    public func batchDeleteServerIds(serverIds: [Int]) {
        LinkdingPersistenceController.shared.viewContext.performAndWait {
            for serverId in serverIds {
                guard let tag = self.tagStore.getByServerId(serverId: serverId) else {
                    return
                }
                LinkdingPersistenceController.shared.viewContext.delete(tag)
            }
            try? LinkdingPersistenceController.shared.viewContext.save()
        }
    }
    
    private func getOrCreateEntity(serverId: Int?) -> LinkdingTagEntity {
        guard let id = serverId else {
            return LinkdingTagEntity.init(context: LinkdingPersistenceController.shared.viewContext)
        }
        
        guard let entity = self.tagStore.getByServerId(serverId: id) else {
            return LinkdingTagEntity.init(context: LinkdingPersistenceController.shared.viewContext)
        }
        
        return entity
    }
}
