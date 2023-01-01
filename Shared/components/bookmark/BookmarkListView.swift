//
// BookmarkListView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public protocol FilteredBookmarkStore<ID> {
    associatedtype ID: Hashable
    func filter(text: String) -> [Bookmark<ID>]
}

public struct BookmarkListView<Content: View, ID: Hashable>: View {
    var bookmarkStore: any FilteredBookmarkStore<ID>
    var showLinkButton: Bool
    var showTags: Bool
    var showDescription: Bool
    var tapHandler: (Bookmark<ID>) -> Void
    var deleteHandler: (Bookmark<ID>) -> Void
    var preListView: () -> Content
    
    public init(
        bookmarkStore: any FilteredBookmarkStore<ID>,
        showLinkButton: Bool = true,
        showTags: Bool = true,
        showDescription: Bool = true,
        tapHandler: @escaping (Bookmark<ID>) -> Void = { _ in },
        deleteHandler: @escaping (Bookmark<ID>) -> Void = { _ in },
        @ViewBuilder preListView: @escaping () -> Content = { EmptyView() }
    ) {
        self.bookmarkStore = bookmarkStore
        self.showLinkButton = showLinkButton
        self.showDescription = showDescription
        self.showTags = showTags
        self.tapHandler = tapHandler
        self.deleteHandler = deleteHandler
        self.preListView = preListView
    }
    
    @State private var searchText: String = ""
    
    public var body: some View {
        List {
            self.preListView()
            ForEach(self.filteredBookmarks()) { bookmark in
                BookmarkView(
                    bookmark: bookmark,
                    showLinkButton: self.showLinkButton,
                    showTags: self.showTags,
                    showDescription: self.showDescription,
                    tapHandler: self.tapHandler
                )
            }
            .onDelete(perform: self.onDelete)
        }
        .searchable(text: self.$searchText)
    }
    
    private func filteredBookmarks() -> [Bookmark<ID>] {
        return self.bookmarkStore.filter(text: self.searchText)
    }
    
    private func onDelete(_ offsets: IndexSet) {
        for index in offsets {
            let bookmark = self.filteredBookmarks()[index]
            self.deleteHandler(bookmark)
        }
    }
}

struct BookmarkListView_Previews: PreviewProvider {
    struct PreviewBookmarkStore: FilteredBookmarkStore {
        func filter(text: String) -> [Bookmark<UUID>] {
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
        BookmarkListView(bookmarkStore: store, showLinkButton: false, showTags: false, showDescription: false)
        BookmarkListView(bookmarkStore: store, preListView: {
            Section() {
                SyncErrorView(errorDetails: "Some more details about the error.")
            }
        })
    }
}
