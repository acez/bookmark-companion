//
// LinkdingBookmarkUpdateDto.swift
// Created by Christian Wilhelm
//

import Foundation

struct LinkdingBookmarkUpdateDto: Codable {
    var url: String
    var title: String
    var description: String
    var isArchived: Bool
    var unread: Bool
    var shared: Bool
    var tagNames: [String]

    enum CodingKeys: String, CodingKey {
        case url
        case title
        case description
        case isArchived = "is_archived"
        case unread
        case shared
        case tagNames = "tag_names"
    }
}
