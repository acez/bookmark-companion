//
// LinkdingTagBookmarksView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding

struct LinkdingTagBookmarksView: View {
    @EnvironmentObject var bookmarkStore: LinkdingBookmarkStore

    var tag: LinkdingTagEntity?
    var title: String

    var body: some View {
            List {
                if self.bookmarks().count > 0 {
                    ForEach(self.bookmarks()) { bookmark in
                        LinkdingBookmarkView(bookmark: bookmark, showTags: false)
                    }
                } else {
                    Text("No bookmarks for this tag")
                }
            }
            .navigationTitle("Bookmarks for \(self.title)")
    }

    private func bookmarks() -> [LinkdingBookmarkEntity] {
        guard let tagEntity = self.tag else {
            return bookmarkStore.untagged
        }
        return tagEntity.bookmarks
    }
}
