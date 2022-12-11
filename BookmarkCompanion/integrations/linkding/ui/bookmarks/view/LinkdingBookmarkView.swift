//
// LinkdingBookmarkView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding
import Shared

struct LinkdingBookmarkView: View {
    @ObservedObject var bookmark: LinkdingBookmarkEntity
    var showTags: Bool

    @State var bookmarkEditorOpen: Bool = false

    var body: some View {
        HStack {
            if (self.showTags && self.bookmark.tagNames.count > 0) {
                VStack(alignment: .leading) {
                    Text(self.bookmark.displayTitle.trimmingCharacters(in: .whitespacesAndNewlines))
                        .lineLimit(1)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(self.bookmark.tagNames, id: \.self) { tag in
                                TagElementComponent(name: tag)
                            }
                        }
                    }
                }
                    .onTapGesture(perform: {
                        self.bookmarkEditorOpen = true
                    })
            } else {
                Text(self.bookmark.displayTitle.trimmingCharacters(in: .whitespacesAndNewlines))
                    .lineLimit(1)
                    .onTapGesture(perform: {
                        self.bookmarkEditorOpen = true
                    })
            }
            Spacer()
            UrlLinkView(url: bookmark.url)
        }
            .sheet(isPresented: self.$bookmarkEditorOpen) {
                BookmarkEditor(bookmark: self.bookmark)
            }
    }
}
