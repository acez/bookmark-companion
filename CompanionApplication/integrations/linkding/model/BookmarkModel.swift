//
// BookmarkModel.swift
// Created by Christian Wilhelm
//

import Foundation

public struct BookmarkModel {
    var serverId: Int?
    var url: String
    var title: String
    var description: String
    var websiteTitle: String?
    var websiteDescription: String?
    var archived: Bool
    var unread: Bool
    var shared: Bool
    var dateAdded: Date?
    var dateModified: Date?
    var tags: [String]
}

extension LinkdingBookmarkEntity {
    public func toModel() -> BookmarkModel {
        return BookmarkModel(
            serverId: self.serverId == 0 ? nil : self.serverId,
            url: self.url,
            title: self.title,
            description: self.urlDescription,
            websiteTitle: self.websiteTitle,
            websiteDescription: self.websiteDescription,
            archived: self.isArchived,
            unread: self.unread,
            shared: self.shared,
            dateAdded: self.dateAdded,
            dateModified: self.dateModified,
            tags: self.tagNames
        )
    }
}
