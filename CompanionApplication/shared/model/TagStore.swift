//
//  TagStore.swift
//  Created by Christian Wilhelm
//

import Foundation

public protocol TagStore<ID> {
    associatedtype ID: Hashable
    func filter(text: String?) -> [Tag<ID>]
}
