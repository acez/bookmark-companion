//
//  BookmarkListItemView.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct BookmarkListItemView<ID: Hashable>: View {
    @AppStorage(SharedSettingKeys.showDescription.rawValue, store: AppStorageSupport.shared.sharedStore) var showDescription: Bool = false
    
    var bookmark: Bookmark<ID>
    
    var body: some View {
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
        }
    }
}

#Preview {
    BookmarkListItemView(
        bookmark: Bookmark(id: UUID(), title: "Dummy-Title", url: "https://dummy", tags: [])
    )
}
