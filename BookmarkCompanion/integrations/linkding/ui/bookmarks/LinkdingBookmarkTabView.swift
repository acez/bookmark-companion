//
// LinkdingBookmarkTabView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding
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
    
    @State var bookmarkToEdit: Bookmark<Int>? = nil

    var body: some View {
        NavigationView {
            VStack {
                BookmarkListView(
                    bookmarkStore: self,
                    tapHandler: { bookmark in
                        self.bookmarkToEdit = bookmark
                    },
                    deleteHandler: { bookmark in
                        print(bookmark)
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
                        let entity = self.bookmarkStore.getByServerId(serverId: bookmark.id)
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


    private func deleteBookmark(bookmark: Bookmark<Int>) {
        // TODO: How to delete unsynced bookmarks -> maybe add a internal id
        guard let entity = self.bookmarkStore.getByServerId(serverId: bookmark.id) else {
            return
        }
        let repository = LinkdingBookmarkRepository(bookmarkStore: self.bookmarkStore, tagStore: self.tagStore)
        repository.markAsDeleted(bookmark: entity)
    }

}

extension LinkdingBookmarkTabView: FilteredBookmarkStore {
    func filter(text: String) -> [Shared.Bookmark<Int>] {
        return self.bookmarkStore.filtered(showArchived: self.showArchived, showUnreadOnly: self.showUnread, filterText: text)
            .map {
                Bookmark(id: $0.serverId, title: $0.displayTitle, url: $0.url, description: $0.websiteDescription, tags: $0.tags)
            }
    }
}
