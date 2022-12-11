//
// BookmarkView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public struct BookmarkView: View {
    var bookmark: Bookmark
    var showLinkButton: Bool = true
    var showTags: Bool = true
    var tapHandler: () -> Void = {}


    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.bookmark.title.trimmingCharacters(in: .whitespacesAndNewlines))
                    .lineLimit(1)
                if self.bookmark.tags.count > 0 && self.showTags {
                    TagListView(tags: self.bookmark.tags)
                }
            }
                .onTapGesture(perform: self.tapHandler)
            if self.showLinkButton {
                Spacer()
                UrlLinkView(url: self.bookmark.url)
            }
        }
    }
}
