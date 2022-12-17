//
// BookmarkListView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public protocol FilteredBookmarkStore {
    func filter(text: String) -> [Bookmark]
}

public struct BookmarkListView: View {
    var bookmarkStore: FilteredBookmarkStore
    
    
    public init(bookmarkStore: FilteredBookmarkStore) {
        self.bookmarkStore = bookmarkStore
    }
    
    @State private var searchText: String = ""
    
    public var body: some View {
        List {
            ForEach(self.filteredBookmarks()) { bookmark in
                BookmarkView(bookmark: bookmark)
            }
        }
        .searchable(text: self.$searchText)
    }
    
    private func filteredBookmarks() -> [Bookmark] {
        return self.bookmarkStore.filter(text: self.searchText)
    }
}

struct BookmarkListView_Previews: PreviewProvider {
    struct PreviewBookmarkStore: FilteredBookmarkStore {
        func filter(text: String) -> [Bookmark] {
            return [
                Bookmark(id: UUID(), title: "bookmark-1", url: "https://www.github.com", tags: [Tag(id: UUID(), name: "tag-1")]),
                Bookmark(id: UUID(), title: "bookmark-2", url: "https://www.github.com", tags: []),
                Bookmark(id: UUID(), title: "bookmark-3", url: "https://www.github.com", tags: [Tag(id: UUID(), name: "tag-2"), Tag(id: UUID(), name: "tag-3")]),
                Bookmark(id: UUID(), title: "bookmark-4", url: "https://www.github.com", description: "A dummy description", tags: []),
                Bookmark(id: UUID(), title: "bookmark-5", url: "https://www.github.com", description: "A dummy description", tags: [Tag(id: UUID(), name: "tag-4")])
            ]
        }
    }
    static let store = PreviewBookmarkStore()
    
    static var previews: some View {
        BookmarkListView(bookmarkStore: store)
    }
}
