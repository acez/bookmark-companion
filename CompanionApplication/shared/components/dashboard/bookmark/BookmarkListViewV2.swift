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

    var body: some View {
        Form {
            ForEach(self.bookmarks) { bookmark in
                HStack(alignment: .top) {
                    BookmarkListItemView(bookmark: bookmark)
                    Spacer()
                    UrlLinkView(url: bookmark.url)
                }
            }
        }
        .navigationTitle(self.title)
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
