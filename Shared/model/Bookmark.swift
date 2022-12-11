//
// Bookmark.swift
// Created by Christian Wilhelm
//

import Foundation

public struct Bookmark {
    var id: UUID
    var title: String
    var url: String
    var description: String?
    var tags: [Tag]
}
