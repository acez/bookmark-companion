//
// LinkdingTagBookmarksView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Shared

struct LinkdingTagBookmarksView: View {
    @EnvironmentObject var bookmarkStore: LinkdingBookmarkStore
    
    @AppStorage(LinkdingSettingKeys.bookmarkSortField.rawValue, store: AppStorageSupport.shared.sharedStore)  var sortField: SortField = .url
    @AppStorage(LinkdingSettingKeys.bookmarkSortOrder.rawValue, store: AppStorageSupport.shared.sharedStore) var sortOrder: SortOrder = .ascending
    @AppStorage(LinkdingSettingKeys.tagViewBookmarkDescription.rawValue, store: AppStorageSupport.shared.sharedStore) var viewBookmarkDescription: Bool = false
    @AppStorage(LinkdingSettingKeys.tagViewBookmarkTags.rawValue, store: AppStorageSupport.shared.sharedStore) var viewBookmarkTags: Bool = false

    @State var bookmarkToEdit: Bookmark<UUID>? = nil
    
    var tag: LinkdingTagEntity?
    var title: String

    var body: some View {
        VStack {
            BookmarkListView(
                bookmarkStore: self,
                showTags: self.viewBookmarkTags,
                showDescription: self.viewBookmarkDescription,
                enableDelete: false,
                tapHandler: { bookmark in
                    self.bookmarkToEdit = bookmark
                }
            )
                .navigationTitle("Bookmarks for \(self.title)")
                .sheet(item: self.$bookmarkToEdit) { bookmark in
                    let entity = self.bookmarkStore.getByInternalId(internalId: bookmark.id)
                    if entity != nil {
                        BookmarkEditor(bookmark: entity!)
                    }
                }
        }
    }
}

extension LinkdingTagBookmarksView: FilteredBookmarkStore {
    func filter(text: String) -> [Shared.Bookmark<UUID>] {
        let bookmarkSorter = BookmarkSorter(sortField: self.sortField, sortOrder: self.sortOrder)
        let bookmarks = self.tag != nil ? self.tag!.bookmarks : self.bookmarkStore.untagged
        return self.bookmarkStore.filtered(showArchived: true, showUnreadOnly: false, filterText: text)
            .filter {
                bookmarks.contains($0)
            }
            .sorted {
                bookmarkSorter.compareBookmark(a: $0, b: $1)
            }
            .map {
                Bookmark(id: $0.internalId, title: $0.displayTitle, url: $0.url, description: $0.displayDescription, tags: $0.tags)
            }
    }
}
