//
// LinkdingBookmarkTabView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Shared

struct LinkdingBookmarkTabView: View {
    @EnvironmentObject var bookmarkStore: LinkdingBookmarkStore
    @EnvironmentObject var tagStore: LinkdingTagStore

    @AppStorage(LinkdingSettingKeys.bookmarkFilterArchived.rawValue, store: AppStorageSupport.shared.sharedStore) var showArchived: Bool = false
    @AppStorage(LinkdingSettingKeys.bookmarkFilterUnread.rawValue, store: AppStorageSupport.shared.sharedStore) var showUnread: Bool = false
    @AppStorage(LinkdingSettingKeys.syncHadError.rawValue, store: AppStorageSupport.shared.sharedStore) var syncHadError: Bool = false
    @AppStorage(LinkdingSettingKeys.syncErrorMessage.rawValue, store: AppStorageSupport.shared.sharedStore) var syncErrorMessage: String = ""
    
    @AppStorage(LinkdingSettingKeys.bookmarkSortField.rawValue, store: AppStorageSupport.shared.sharedStore)  var sortField: SortField = .url
    @AppStorage(LinkdingSettingKeys.bookmarkSortOrder.rawValue, store: AppStorageSupport.shared.sharedStore) var sortOrder: SortOrder = .ascending

    @State var filterViewOpen: Bool = false
    @State var createBookmarkOpen: Bool = false
    @State var bookmarkToEdit: Bookmark<UUID>? = nil
    
    @Binding var openConfig: Bool

    var body: some View {
        NavigationView {
            VStack {
                BookmarkListView(
                    bookmarkStore: self,
                    tapHandler: { bookmark in
                        self.bookmarkToEdit = bookmark
                    },
                    deleteHandler: { bookmark in
                        self.deleteBookmark(bookmark: bookmark)
                    },
                    preListView: {
                        if self.syncHadError {
                            Section() {
                                SyncErrorView(errorDetails: self.syncErrorMessage)
                            }
                        }
                    }
                )
                    .navigationTitle("Bookmarks")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            ConfigurationButton(actionHandler: {
                                self.openConfig.toggle()
                            })
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button(action: {
                                self.filterViewOpen = true
                            }) {
                                Image(systemName: "slider.horizontal.3")
                            }
                            Button(action: {
                                self.createBookmarkOpen = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .refreshable {
                        let syncClient = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                        try? await syncClient.sync()
                    }
            }
        }
            .sheet(isPresented: self.$filterViewOpen) {
                LinkdingBookmarkTabSettingsView()
            }
            .sheet(isPresented: self.$createBookmarkOpen) {
                LinkdingCreateBookmarkView()
            }
            .sheet(item: self.$bookmarkToEdit) { bookmark in
                let entity = self.bookmarkStore.getByInternalId(internalId: bookmark.id)
                if entity != nil {
                    BookmarkEditor(bookmark: entity!)
                }
            }
            .navigationViewStyle(.stack)
    }


    private func deleteBookmark(bookmark: Bookmark<UUID>) {
        guard let entity = self.bookmarkStore.getByInternalId(internalId: bookmark.id) else {
            return
        }
        let repository = LinkdingBookmarkRepository(bookmarkStore: self.bookmarkStore, tagStore: self.tagStore)
        repository.markAsDeleted(bookmark: entity)
    }

}

extension LinkdingBookmarkTabView: FilteredBookmarkStore {
    func filter(text: String) -> [Shared.Bookmark<UUID>] {
        let bookmarkSorter = BookmarkSorter(sortField: self.sortField, sortOrder: self.sortOrder)
        return self.bookmarkStore.filtered(showArchived: self.showArchived, showUnreadOnly: self.showUnread, filterText: text)
            .sorted {
                bookmarkSorter.compareBookmark(a: $0, b: $1)
            }
            .map {
                Bookmark(id: $0.internalId, title: $0.displayTitle, url: $0.url, description: $0.displayDescription, tags: $0.tags)
            }
    }
}
