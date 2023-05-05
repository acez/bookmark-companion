//
// Bookmark.swift
// Created by Christian Wilhelm
//

import Foundation

public struct Bookmark<ID: Hashable>: Identifiable {
    public var id: ID
    public var title: String
    public var url: String
    public var description: String?
    public var tags: [Tag<ID>]
    
    public init(id: ID, title: String, url: String, description: String? = nil, tags: [Tag<ID>]) {
        self.id = id
        self.title = title
        self.url = url
        self.description = description
        self.tags = tags
    }
}
