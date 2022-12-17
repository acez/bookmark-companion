//
// TagListView.swift
// Created by Christian Wilhelm
//

import SwiftUI

struct TagListView: View {
    var tags: [Tag]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(self.tags, id: \.id) { tag in
                    TagListItemView(tag: tag)
                }
            }
        }
    }
}

struct TagListView_Previews: PreviewProvider {
    static let tags = [
        Tag(id: UUID(), name: "tag-1"),
        Tag(id: UUID(), name: "tag-2")
    ]
    
    static var previews: some View {
        TagListView(tags: tags)
    }
}
