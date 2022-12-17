//
// Tag.swift
// Created by Christian Wilhelm
//

import Foundation

public struct Tag: Identifiable {
    public var id: UUID
    public var name: String
    
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}
