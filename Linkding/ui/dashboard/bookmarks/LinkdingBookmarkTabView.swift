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

    @State var textFilter: String = ""
    @State var filterViewOpen: Bool = false
    @State var createBookmarkOpen: Bool = false
    
    @State var bookmarkToEdit: Bookmark<UUID>? = nil

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
                    .searchable(text: self.$textFilter)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            ConfigurationButton()
                        }
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button(action: {
                                self.filterViewOpen = true
                            }) {
                                if (self.showUnread == true || self.showArchived == true) {
                                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                } else {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                }
                            }
                            Button(action: {
                                self.createBookmarkOpen = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: self.$filterViewOpen) {
                        LinkdingBookmarkTabFilterView()
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
                    .refreshable {
                        let syncClient = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                        try? await syncClient.sync()
                    }
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
        return self.bookmarkStore.filtered(showArchived: self.showArchived, showUnreadOnly: self.showUnread, filterText: text)
            .map {
                Bookmark(id: $0.internalId, title: $0.displayTitle, url: $0.url, description: $0.websiteDescription, tags: $0.tags)
            }
    }
}
