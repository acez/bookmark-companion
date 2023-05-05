//
// Tag.swift
// Created by Christian Wilhelm
//

import Foundation

public struct Tag<ID: Hashable>: Identifiable {
    public var id: ID
    public var name: String
    
    public init(id: ID, name: String) {
        self.id = id
        self.name = name
    }
}
