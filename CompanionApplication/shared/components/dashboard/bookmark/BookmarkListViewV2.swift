//
//  BookmarkListView.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct BookmarkListViewV2<ID: Hashable>: View {
    var title: String
    var bookmarks: [Bookmark<ID>]
    
    var body: some View {
        Form {
            ForEach(self.bookmarks) { bookmark in
                Text(bookmark.title)
            }
        }
        .navigationTitle(self.title)
    }
}

#Preview {
    BookmarkListViewV2(
        title: "Dummy Tag",
        bookmarks: [
            Bookmark(id: UUID(), title: "Dummy Title 1", url: "http://dummy-url-1", tags: []),
            Bookmark(id: UUID(), title: "Dummy Title 2", url: "http://dummy-url-2", tags: [])
        ]
    )
}
