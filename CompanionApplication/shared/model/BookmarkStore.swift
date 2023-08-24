//
//  BookmarkStore.swift
//  Created by Christian Wilhelm
//

import Foundation

public enum BookmarkStoreFilter {
    case all
    case unread
}

public protocol BookmarkStore<ID> {
    associatedtype ID: Hashable
    func filter(text: String?, filter: BookmarkStoreFilter?) -> [Bookmark<ID>]
    func byTag(tag: Tag<ID>) -> [Bookmark<ID>]
}

