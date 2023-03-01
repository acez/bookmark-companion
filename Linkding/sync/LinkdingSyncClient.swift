//
// LinkdingSyncClient.swift
// Created by Christian Wilhelm
//

import Foundation
import Shared

public class LinkdingSyncClient: ObservableObject {
    private var apiClient: LinkdingApiClient

    private let tagStore: LinkdingTagStore
    private let tagRepository: LinkdingTagRepository

    private let bookmarkStore: LinkdingBookmarkStore
    private let bookmarkRepository: LinkdingBookmarkRepository

    public init(tagStore: LinkdingTagStore, bookmarkStore: LinkdingBookmarkStore) {
        self.tagStore = tagStore
        self.tagRepository = LinkdingTagRepository(tagStore: tagStore)
        self.bookmarkStore = bookmarkStore
        self.bookmarkRepository = LinkdingBookmarkRepository(bookmarkStore: bookmarkStore, tagStore: tagStore)

        let baseUrl = AppStorageSupport.shared.sharedStore.string(forKey: LinkdingSettingKeys.settingsUrl.rawValue) ?? ""
        let apiToken = (try? SecureSettingsSupport.getSecureSettingString(key: LinkdingSettingKeys.settingsToken.rawValue)) ?? ""
        self.apiClient = LinkdingApiClient(baseUrl: baseUrl, apiToken: apiToken)
    }

    private func syncRunning() -> Bool {
        guard let syncRunning = AppStorageSupport.shared.sharedStore.object(forKey: LinkdingSettingKeys.syncRunning.rawValue) as? Date else {
            return false
        }

        guard let syncThreshold = Calendar.current.date(byAdding: .minute, value: -1, to: Date.now) else {
            // Something is really odd here so probably no sync running
            return false
        }

        return syncThreshold < syncRunning
    }

    public func sync() async throws {
        if (self.syncRunning()) {
            return
        }

        AppStorageSupport.shared.sharedStore.set(false, forKey: LinkdingSettingKeys.syncHadError.rawValue)
        AppStorageSupport.shared.sharedStore.set("", forKey: LinkdingSettingKeys.syncErrorMessage.rawValue)
        AppStorageSupport.shared.sharedStore.setValue(Date.now, forKey: LinkdingSettingKeys.syncRunning.rawValue)
        do {
            try await self.pushNewTags()
            try await self.pushDeletedBookmarks()
            try await self.pushNewBookmarks()
            try await self.pushModifiedBookmarks()
            try await self.syncTags()
            try await self.syncBookmarks()
        } catch (let error) {
            AppStorageSupport.shared.sharedStore.set(true, forKey: LinkdingSettingKeys.syncHadError.rawValue)
            if let apiError = error as? LinkdingApiError {
                AppStorageSupport.shared.sharedStore.set(apiError.message, forKey: LinkdingSettingKeys.syncErrorMessage.rawValue)
            }
            AppStorageSupport.shared.sharedStore.set(nil, forKey: LinkdingSettingKeys.syncRunning.rawValue)
            throw error
        }
        AppStorageSupport.shared.sharedStore.set(nil, forKey: LinkdingSettingKeys.syncRunning.rawValue)
    }

    private func pushDeletedBookmarks() async throws {
        for deletedBookmarks in self.bookmarkStore.onlyLocallyDeletedBookmarks {
            try await self.deleteBookmark(bookmark: deletedBookmarks)
        }
    }

    private func pushNewBookmarks() async throws {
        for newBookmark in self.bookmarkStore.onlyNewBookmarks {
            try await self.createBookmark(bookmark: newBookmark)
        }
    }

    private func pushModifiedBookmarks() async throws {
        for modifiedBookmark in self.bookmarkStore.onlyModifiedBookmarks {
            try await self.updateBookmark(bookmark: modifiedBookmark)
        }
    }
    
    private func pushNewTags() async throws {
        for tag in self.tagStore.onlyLocalTags {
            let updatedTag = try await self.apiClient.createTag(name: tag.name)
            self.tagRepository.updateTag(entity: tag, updateData: TagModel(serverId: updatedTag.id, name: updatedTag.name, dateAdded: updatedTag.dateAdded))
        }
    }

    private func syncTags() async throws {
        let tags = try await self.apiClient.loadTags()
        let updates = tags.map {
            TagModel(serverId: $0.id, name: $0.name, dateAdded: $0.dateAdded)
        }
        self.tagRepository.batchApplyChanges(models: updates)
        
        let allServerIds = self.tagStore.tags.map { $0.serverId }
        let deleteServerIds = self.tagStore.tags
            .filter { !allServerIds.contains($0.serverId) }
            .map { $0.serverId }
        self.tagRepository.batchDeleteServerIds(serverIds: deleteServerIds)
    }

    private func syncBookmarks() async throws {
        let bookmarks = try await self.apiClient.loadBookmarks()
        for bookmarkDto in bookmarks {
            await self.bookmarkRepository.createOrUpdateBookmarkFromServer(
                serverId: bookmarkDto.id,
                url: bookmarkDto.url,
                title: bookmarkDto.title,
                urlDescription: bookmarkDto.description,
                websiteTitle: bookmarkDto.websiteTitle,
                websiteDescription: bookmarkDto.websiteDescription,
                isArchived: bookmarkDto.isArchived,
                unread: bookmarkDto.unread,
                shared: bookmarkDto.shared,
                dateAdded: bookmarkDto.dateAdded,
                dateModified: bookmarkDto.dateModified,
                tags: bookmarkDto.tags
            )
        }
        let allServerIds = bookmarks.map {
            $0.id
        }
        for bookmark in self.bookmarkStore.bookmarks {
            if (!allServerIds.contains(bookmark.serverId)) {
                await self.bookmarkRepository.deleteBookmarkByServerId(serverId: bookmark.serverId)
            }
        }
    }

    private func deleteBookmark(bookmark: LinkdingBookmarkEntity) async throws {
        if (!bookmark.localOnly) {
            try await self.apiClient.deleteBookmark(serverId: bookmark.serverId)
        }
        await self.bookmarkRepository.deleteBookmark(bookmark: bookmark)
    }

    private func createBookmark(bookmark: LinkdingBookmarkEntity) async throws {
        let createdBookmark = try await self.apiClient.createBookmark(
            url: bookmark.url,
            title: bookmark.title,
            description: bookmark.urlDescription,
            isArchived: bookmark.isArchived,
            unread: bookmark.unread,
            shared: bookmark.shared,
            tagNames: bookmark.tagNames
        )
        await self.bookmarkRepository.updateExistingBookmarkFromServer(
            bookmark: bookmark,
            serverId: createdBookmark.id,
            url: createdBookmark.url,
            title: createdBookmark.title,
            urlDescription: createdBookmark.description,
            websiteTitle: createdBookmark.websiteTitle,
            websiteDescription: createdBookmark.websiteDescription,
            isArchived: createdBookmark.isArchived,
            unread: createdBookmark.unread,
            shared: createdBookmark.shared,
            dateAdded: createdBookmark.dateAdded,
            dateModified: createdBookmark.dateModified,
            tags: createdBookmark.tags
        )
    }

    private func updateBookmark(bookmark: LinkdingBookmarkEntity) async throws {
        let bookmarkFromServer = try await self.apiClient.updateBookmark(
            serverId: bookmark.serverId,
            url: bookmark.url,
            title: bookmark.title,
            description: bookmark.urlDescription,
            isArchived: bookmark.isArchived,
            unread: bookmark.unread,
            shared: bookmark.shared,
            tagNames: bookmark.tagNames
        )
        await self.bookmarkRepository.updateExistingBookmarkFromServer(
            bookmark: bookmark,
            serverId: bookmarkFromServer.id,
            url: bookmarkFromServer.url,
            title: bookmarkFromServer.title,
            urlDescription: bookmarkFromServer.description,
            websiteTitle: bookmarkFromServer.websiteTitle,
            websiteDescription: bookmarkFromServer.websiteDescription,
            isArchived: bookmarkFromServer.isArchived,
            unread: bookmarkFromServer.unread,
            shared: bookmarkFromServer.shared,
            dateAdded: bookmarkFromServer.dateAdded,
            dateModified: bookmarkFromServer.dateModified,
            tags: bookmarkFromServer.tags
        )
    }

    public func syncSingleBookmark(bookmark: LinkdingBookmarkEntity) async throws {
        do {
            if (bookmark.locallyDeleted) {
                try await self.deleteBookmark(bookmark: bookmark)
                return
            }

            if (bookmark.localOnly) {
                try await self.createBookmark(bookmark: bookmark)
                return
            }

            if (bookmark.locallyModified) {
                try await self.updateBookmark(bookmark: bookmark)
                return
            }

            // Nothing to be done
        } catch (let error) {
            AppStorageSupport.shared.sharedStore.set(true, forKey: LinkdingSettingKeys.syncHadError.rawValue)
            throw error
        }
    }
    
    public func syncSingleTag(tag: LinkdingTagEntity) async throws {
        do {
            let updatedTag = try await self.apiClient.createTag(name: tag.name)
            self.tagRepository.updateTag(entity: tag, updateData: TagModel(serverId: updatedTag.id, name: updatedTag.name, dateAdded: updatedTag.dateAdded))
        } catch (let error) {
            AppStorageSupport.shared.sharedStore.set(true, forKey: LinkdingSettingKeys.syncHadError.rawValue)
            throw error
        }
    }
}

extension LinkdingSyncClient: BackendSupportClientProtocol {    
    public func isBackendAvailable() async -> Bool {
        do {
            return try await self.apiClient.apiAvailable()
        } catch (_) {
            return false
        }
    }
    
    
}
