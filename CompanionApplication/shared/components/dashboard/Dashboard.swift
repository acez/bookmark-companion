//
//  Dashboard.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct Dashboard<ID: Hashable>: View {
    var bookmarkStore: any BookmarkStore<ID>
    var tagStore: any TagStore<ID>
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        DashboardTile(title: "All bookmarks", count: self.allBookmarksCount(), width: geometry.size.width / 2.0)
                        DashboardTile(title: "Unread bookmarks", count: self.unreadBookmarksCount(), width: geometry.size.width / 2.0, color: Color.blue, iconName: "tray.full.fill")
                    }
                    HStack {
                        VStack {
                            Text("Tags").font(.system(size: 24))
                            ForEach(self.tagStore.filter(text: nil)) { tag in
                                DashboardTagListItem(tagName: tag.name, tagBookmarkCount: self.tagBookmarkCount(tag: tag), width: geometry.size.width)
                            }
                        }
                    }
                    .padding(10)
                }
            }
        }
    }
    
    func allBookmarksCount() -> Int {
        return self.bookmarkStore
            .filter(text: nil, filter: .all)
            .count
    }
    
    func unreadBookmarksCount() -> Int {
        return self.bookmarkStore
            .filter(text: nil, filter: .unread)
            .count
    }
    
    func tagBookmarkCount(tag: Tag<ID>) -> Int {
        return self.bookmarkStore
            .byTag(tag: tag)
            .count
    }
}

struct Dashboard_Previews: PreviewProvider {
    struct PreviewBookmarkStore: BookmarkStore {
        typealias ID = UUID

        func filter(text: String?, filter: BookmarkStoreFilter?) -> [Bookmark<UUID>] {
            if filter == .all {
                return [
                    Bookmark(id: UUID(), title: "Dummy Title 1", url: "http://dummy-url-1", tags: []),
                    Bookmark(id: UUID(), title: "Dummy Title 2", url: "http://dummy-url-2", tags: [])
                ]
            } else {
                return [
                    Bookmark(id: UUID(), title: "Dummy Title 3", url: "http://dummy-url-3", tags: [])
                ]
            }
        }
        
        func byTag(tag: Tag<UUID>) -> [Bookmark<UUID>] {
            return []
        }
    }
    
    struct PreviewTagStore: TagStore {
        typealias ID = UUID
        
        func filter(text: String?) -> [Tag<UUID>] {
            return [
                Tag(id: UUID(), name: "tag-1"),
                Tag(id: UUID(), name: "tag-2"),
                Tag(id: UUID(), name: "tag-3")
            ]
        }
    }

    static var previews: some View {
        Dashboard(bookmarkStore: PreviewBookmarkStore(), tagStore: PreviewTagStore())
    }
}
