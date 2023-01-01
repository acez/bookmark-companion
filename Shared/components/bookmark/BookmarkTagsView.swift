//
// BookmarkTagsView.swift
// Created by Christian Wilhelm
//

import SwiftUI

struct BookmarkTagsView<ID: Hashable>: View {
    var tags: [Tag<ID>]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(self.tags) { tag in
                    HStack {
                        Text("#\(tag.name)")
                            .lineLimit(1)
                    }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange)
                        .cornerRadius(15)
                }
            }
        }
    }
}

struct BookmarkTagsView_Previews: PreviewProvider {
    static let tags = [
        Tag(id: UUID(), name: "tag-1"),
        Tag(id: UUID(), name: "tag-2"),
        Tag(id: UUID(), name: "tag-3"),
    ]
    
    static var previews: some View {
        BookmarkTagsView(tags: tags)
    }
}
