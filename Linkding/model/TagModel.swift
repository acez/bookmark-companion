//
// TagModel.swift
// Created by Christian Wilhelm
//

import Foundation

public struct TagModel {
    public init(serverId: Int? = nil, name: String, dateAdded: Date? = nil) {
        self.serverId = serverId
        self.name = name
        self.dateAdded = dateAdded
    }
    
    public var serverId: Int?
    public var name: String
    public var dateAdded: Date?
}
