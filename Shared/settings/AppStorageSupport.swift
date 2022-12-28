//
// AppStorageSupport.swift
// Created by Christian Wilhelm
//

import Foundation

public struct AppStorageSupport {
    public static let shared: AppStorageSupport = AppStorageSupport()

    private(set) public var sharedStore: UserDefaults

    public init() {
        self.sharedStore = UserDefaults(suiteName: "group.bookmarkcompanion")!
    }
}
