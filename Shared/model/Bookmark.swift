//
// Bookmark.swift
// Created by Christian Wilhelm
//

import Foundation

public struct Bookmark: Identifiable {
    public var id: UUID
    public var title: String
    public var url: String
    public var description: String?
    public var tags: [Tag]
    
    public init(id: UUID, title: String, url: String, description: String? = nil, tags: [Tag]) {
        self.id = id
        self.title = title
        self.url = url
        self.description = description
        self.tags = tags
    }
}
