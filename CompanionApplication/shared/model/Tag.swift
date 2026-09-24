//
// Tag.swift
// Created by Christian Wilhelm
//

import Foundation

public struct Tag<ID: Hashable>: Identifiable {
    public var id: ID
    public var name: String
    public var favorite: Bool

    public init(id: ID, name: String, favorite: Bool = false) {
        self.id = id
        self.name = name
        self.favorite = favorite
    }
}
