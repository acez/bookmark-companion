//
// TagListItemView.swift
// Created by Christian Wilhelm
//

import SwiftUI

struct TagListItemView: View {
    var tag: Tag

    var body: some View {
        HStack {
            Text("#\(self.tag.name)")
                .lineLimit(1)
        }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.orange)
            .cornerRadius(15)
    }
}


struct TagListItemView_Previews: PreviewProvider {
    static let tag = Tag(id: UUID(), name: "tag-1")
    
    static var previews: some View {
        TagListItemView(tag: tag)
    }
}

