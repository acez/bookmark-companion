//
// LinkdingBookmarkTabView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding

struct LinkdingBookmarkTabView: View {
    @EnvironmentObject var bookmarkStore: LinkdingBookmarkStore
    @EnvironmentObject var tagStore: LinkdingTagStore

    @AppStorage("linkding.bookmarks.filter.archived", store: AppStorageSupport.shared.sharedStore) var showArchived: Bool = false
    @AppStorage("linkding.bookmarks.filter.unread", store: AppStorageSupport.shared.sharedStore) var showUnread: Bool = false
    @AppStorage(LinkdingSettingKeys.syncHadError.rawValue, store: AppStorageSupport.shared.sharedStore) var syncHadError: Bool = false
    @AppStorage(LinkdingSettingKeys.syncErrorMessage.rawValue, store: AppStorageSupport.shared.sharedStore) var syncErrorMessage: String = ""

    @State var textFilter: String = ""
    @State var filterViewOpen: Bool = false
    @State var createBookmarkOpen: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    if (self.syncHadError) {
                        Section() {
                            Text("Synchronization error.")
                                .foregroundColor(.red)
                            if (self.syncErrorMessage != "") {
                                Text(self.syncErrorMessage)
                            }
                            Text("Please check your URL and your Token in the configuration dialog.")
                        }
                    }
                    ForEach(self.filteredBookmarks()) { bookmark in
                        LinkdingBookmarkView(bookmark: bookmark, showTags: true)
                    }
                        .onDelete(perform: self.deleteBookmark)
                }
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
                    .refreshable {
                        let syncClient = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                        try? await syncClient.sync()
                    }
            }
        }
            .navigationViewStyle(.stack)
    }

    private func filteredBookmarks() -> [LinkdingBookmarkEntity] {
        return self.bookmarkStore
            .filtered(showArchived: self.showArchived, showUnreadOnly: self.showUnread, filterText: self.textFilter)
    }

    private func deleteBookmark(at offsets: IndexSet) {
        for index in offsets {
            let bookmark = self.filteredBookmarks()[index]
            let repository = LinkdingBookmarkRepository(bookmarkStore: self.bookmarkStore, tagStore: self.tagStore)
            repository.markAsDeleted(bookmark: bookmark)
        }
    }

}
