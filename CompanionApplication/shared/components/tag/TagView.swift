//
// TagView.swift
// Created by Christian Wilhelm
//

import SwiftUI

struct TagView<ID: Hashable>: View {
    var tag: Tag<ID>
    
    var body: some View {
        Text(self.tag.name)
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(tag: Tag(id: UUID(), name: "tag-1"))
    }
}
