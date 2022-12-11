//
// LinkdingBookmarkDto.swift
// Created by Christian Wilhelm
//

import Foundation

struct LinkdingBookmarkDtoList: Codable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [LinkdingBookmarkDto]
}


struct LinkdingBookmarkDto: Codable, Identifiable {
    var id: Int
    var url: String
    var title: String
    var description: String
    var websiteTitle: String?
    var websiteDescription: String?
    var isArchived: Bool
    var unread: Bool
    var shared: Bool
    var tags: [String]
    var dateAdded: Date
    var dateModified: Date

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case title
        case description
        case websiteTitle = "website_title"
        case websiteDescription = "website_description"
        case isArchived = "is_archived"
        case unread
        case shared
        case tags = "tag_names"
        case dateAdded = "date_added"
        case dateModified = "date_modified"
    }
}
