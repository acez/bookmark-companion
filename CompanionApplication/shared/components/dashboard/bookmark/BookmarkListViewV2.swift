//
//  BookmarkListView.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct BookmarkListViewV2<ID: Hashable, CreateView: View>: View {
    var title: String
    var bookmarks: [Bookmark<ID>]
    @ViewBuilder var createBookmarkView: () -> CreateView

    @State private var createBookmarkOpen: Bool = false
    @State private var searchText: String = ""

    private var filteredBookmarks: [Bookmark<ID>] {
        if self.searchText.isEmpty {
            return self.bookmarks
        }
        let searchText = self.searchText.lowercased()
        let tagSearchText = searchText.first == "#" ?
            String(searchText.dropFirst()) :
            searchText
        return self.bookmarks.filter { bookmark in
            let tagFound = bookmark.tags.contains {
                $0.name.lowercased().starts(with: tagSearchText)
            }
            let titleFound = bookmark.title.lowercased().contains(searchText)
            let urlFound = bookmark.url.lowercased().contains(searchText)
            let descriptionFound = bookmark.description?.lowercased().contains(searchText) ?? false
            return tagFound || titleFound || urlFound || descriptionFound
        }
    }

    var body: some View {
        Form {
            ForEach(self.filteredBookmarks) { bookmark in
                HStack(alignment: .top) {
                    BookmarkListItemView(bookmark: bookmark)
                    Spacer()
                    UrlLinkView(url: bookmark.url)
                }
            }
        }
        .navigationTitle(self.title)
        .searchable(text: self.$searchText, prompt: "Search bookmarks")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.createBookmarkOpen = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: self.$createBookmarkOpen) {
            self.createBookmarkView()
        }
    }
}

#Preview {
    NavigationStack {
        BookmarkListViewV2(
            title: "Dummy Tag",
            bookmarks: [
                Bookmark(id: UUID(), title: "Dummy Title 1", url: "http://dummy-url-1", tags: []),
                Bookmark(id: UUID(), title: "Dummy Title 2", url: "http://dummy-url-2", tags: [])
            ],
            createBookmarkView: { Text("Create bookmark") }
        )
    }
}
