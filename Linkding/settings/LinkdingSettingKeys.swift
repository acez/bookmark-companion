//
// LinkdingSettingKeys.swift
// Created by Christian Wilhelm
//

import Foundation

public enum LinkdingSettingKeys: String {
    case bookmarkFilterArchived = "linkding.bookmarks.filter.archived"
    case bookmarkFilterUnread = "linkding.bookmarks.filter.unread"
    case bookmarkSortField = "linkding.bookmarks.sort.field"
    case bookmarkSortOrder = "linkding.bookmarks.sort.order"

    case settingsUrl = "linkding.settings.url"
    case settingsToken = "linkding.settings.token"
    case configComplete = "linkding.configured"

    case createBookmarkDefaultUnread = "linkding.create.default.unread"
    case createBookmarkDefaultShared = "linkding.create.default.shared"
    case createBookmarkDefaultArchived = "linkding.create.default.archived"
    
    case tagFilterOnlyUsed = "linkding.tags.filter.onlyused"

    case syncRunning = "linkding.sync.running"
    case syncHadError = "linkding.sync.error"
    case syncErrorMessage = "linkding.sync.error.message"

    case persistenceHistoryLastTransactionTimestamp = "linkding.persistence.lastTransactionTimestamp"
}
