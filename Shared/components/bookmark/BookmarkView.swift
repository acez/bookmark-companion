//
// BookmarkView.swift
// Created by Christian Wilhelm
//

import SwiftUI

struct BookmarkView<ID: Hashable>: View {
    var bookmark: Bookmark<ID>
    var showLinkButton: Bool = true
    var showTags: Bool = true
    var showDescription: Bool = true
    var tapHandler: (Bookmark<ID>) -> Void = { _ in }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.bookmark.title.trimmingCharacters(in: .whitespacesAndNewlines))
                    .fontWeight(.bold)
                    .lineLimit(1)
                if self.bookmark.description != nil && self.bookmark.description != "" && self.showDescription == true {
                    HStack(alignment: .top) {
                        Text(self.bookmark.description!)
                            .fontWeight(.light)
                    }
                }
                if self.bookmark.tags.count > 0 && self.showTags {
                    BookmarkTagsView(tags: self.bookmark.tags)
                }
            }
                .onTapGesture(perform: {
                    self.tapHandler(self.bookmark)
                })
            if self.showLinkButton {
                Spacer()
                UrlLinkView(url: self.bookmark.url)
            }
        }
    }
}

struct BookmarkView_Previews: PreviewProvider {
    static let bookmark = Bookmark(id: UUID(), title: "Dummy Bookmark Title", url: "https://www.github.com", description: "This is a dummy description", tags: [
        Tag(id: UUID(), name: "tag-1"),
        Tag(id: UUID(), name: "tag-2")
    ])
    
    static var previews: some View {
        BookmarkView(bookmark: bookmark)
        BookmarkView(bookmark: bookmark, showTags: false)
        BookmarkView(bookmark: bookmark, showDescription: false)
        BookmarkView(bookmark: bookmark, showLinkButton: false)
    }
}
