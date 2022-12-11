//
// LinkdingTagDto.swift
// Created by Christian Wilhelm
//

import Foundation

struct LinkdingTagDto: Codable, Identifiable {
    var id: Int
    var name: String
    var dateAdded: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dateAdded = "date_added"
    }
}

struct LinkdingTagListDto: Codable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [LinkdingTagDto]
}
