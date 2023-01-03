//
// LinkdingTagBookmarksView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding
import Shared

struct LinkdingTagBookmarksView: View {
    @EnvironmentObject var bookmarkStore: LinkdingBookmarkStore

    var tag: LinkdingTagEntity?
    var title: String

    var body: some View {
            List {
                if self.bookmarks().count > 0 {
                    ForEach(self.bookmarks()) { bookmark in
                        BookmarkView(bookmark: bookmark, showTags: false)
                    }
                } else {
                    Text("No bookmarks for this tag")
                }
            }
            .navigationTitle("Bookmarks for \(self.title)")
    }

    private func bookmarks() -> [Bookmark<UUID>] {
        let bookmarks = self.tag != nil ? self.tag!.bookmarks : self.bookmarkStore.untagged
        return bookmarks.map {
            Bookmark(id: $0.internalId, title: $0.displayTitle, url: $0.url, description: $0.websiteDescription, tags: $0.tags.map { Tag(id: $0.id, name: $0.name) })
        }
    }
}
