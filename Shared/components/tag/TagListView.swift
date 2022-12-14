//
// TagListView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public protocol FilteredTagStore<ID> {
    associatedtype ID: Hashable
    func filter(text: String) -> [Tag<ID>]
}

public struct TagListView<ID: Hashable>: View {
    var tagStore: any FilteredTagStore<ID>
    
    public init(tagStore: any FilteredTagStore<ID>) {
        self.tagStore = tagStore
    }
    
    @State private var searchText: String = ""

    public var body: some View {
        List {
            ForEach(self.filteredTags()) { tag in
                TagView(tag: tag)
            }
        }
        .searchable(text: self.$searchText)
    }
    
    private func filteredTags() -> [Tag<ID>] {
        return self.tagStore.filter(text: self.searchText)
    }
}

struct TagListView_Previews: PreviewProvider {
    struct PreviewTagStore: FilteredTagStore {
        func filter(text: String) -> [Tag<UUID>] {
            return [
                Tag(id: UUID(), name: "tag-1"),
                Tag(id: UUID(), name: "tag-2"),
                Tag(id: UUID(), name: "tag-3"),
                Tag(id: UUID(), name: "tag-4")
            ]
        }
    }
    static let store = PreviewTagStore()
    
    static var previews: some View {
        TagListView(tagStore: store)
    }
}
