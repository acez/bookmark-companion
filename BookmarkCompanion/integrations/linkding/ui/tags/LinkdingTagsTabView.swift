//
// LinkdingTagsTabView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding
import Shared

struct LinkdingTagsTabView: View {
    @EnvironmentObject var tagStore: LinkdingTagStore
    @EnvironmentObject var bookmarkStore: LinkdingBookmarkStore

    @AppStorage(LinkdingSettingKeys.syncHadError.rawValue, store: AppStorageSupport.shared.sharedStore) var syncHadError: Bool = false
    @AppStorage(LinkdingSettingKeys.syncErrorMessage.rawValue, store: AppStorageSupport.shared.sharedStore) var syncErrorMessage: String = ""
    @AppStorage(LinkdingSettingKeys.tagFilterOnlyUsed.rawValue, store: AppStorageSupport.shared.sharedStore) var onlyUsed: Bool = false

    @State var selectedTag: LinkdingTagEntity? = nil
    @State var tagSearchString: String = ""
    
    @State var createSheetOpen: Bool = false
    @State var filterSheetOpen: Bool = false

    var body: some View {
        NavigationView {
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
                if (self.tagSearchString == "" || "untagged".contains(self.tagSearchString.lowercased())) {
                    NavigationLink(destination: LinkdingTagBookmarksView(tag: nil, title: "untagged")) {
                        Text("untagged")
                            .badge(self.bookmarkStore.untagged.count)
                    }
                }
                ForEach(self.filteredTags()) { tag in
                    NavigationLink(destination: LinkdingTagBookmarksView(tag: tag, title: tag.name)) {
                        Text(tag.name)
                            .badge(tag.bookmarks.count)
                    }
                }
            }
                .listStyle(.insetGrouped)
                .navigationTitle("Tags")
                .refreshable {
                    let syncClient = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                    try? await syncClient.sync()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        ConfigurationButton()
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.filterSheetOpen = true
                        }) {
                            if (self.onlyUsed == true) {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            } else {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                            }
                        }
                        Button(action: {
                            self.createSheetOpen = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: self.$createSheetOpen) {
                    CreateTagView()
                }
                .sheet(isPresented: self.$filterSheetOpen) {
                    FilterTagView()
                }
                .searchable(text: self.$tagSearchString)
        }
    }

    private func filteredTags() -> [LinkdingTagEntity] {
        return self.tagStore
            .filteredTags(nameFilter: self.tagSearchString, onlyUsed: self.onlyUsed)
    }
}
