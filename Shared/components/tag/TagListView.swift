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
