//
// LinkdingTagsTabView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Shared

struct LinkdingTagsTabView: View {
    @EnvironmentObject var tagStore: LinkdingTagStore
    @EnvironmentObject var bookmarkStore: LinkdingBookmarkStore

    @AppStorage(LinkdingSettingKeys.syncHadError.rawValue, store: AppStorageSupport.shared.sharedStore) var syncHadError: Bool = false
    @AppStorage(LinkdingSettingKeys.syncErrorMessage.rawValue, store: AppStorageSupport.shared.sharedStore) var syncErrorMessage: String = ""
    @AppStorage(LinkdingSettingKeys.tagFilterOnlyUsed.rawValue, store: AppStorageSupport.shared.sharedStore) var onlyUsed: Bool = false
    
    @AppStorage(LinkdingSettingKeys.tagSortOrder.rawValue, store: AppStorageSupport.shared.sharedStore) var sortOrder: SortOrder = .ascending

    @State var selectedTag: LinkdingTagEntity? = nil
    @State var tagSearchString: String = ""
    @State var createSheetOpen: Bool = false
    @State var filterSheetOpen: Bool = false

    @Binding var openConfig: Bool
    
    var body: some View {
        NavigationView {
            List {
                if self.syncHadError {
                    Section() {
                        SyncErrorView(errorDetails: self.syncErrorMessage)
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
                        ConfigurationButton(actionHandler: {
                            self.openConfig.toggle()
                        })
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.filterSheetOpen = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                        }
                        Button(action: {
                            self.createSheetOpen = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .searchable(text: self.$tagSearchString)
        }
            .sheet(isPresented: self.$createSheetOpen) {
                CreateTagView()
            }
            .sheet(isPresented: self.$filterSheetOpen) {
                FilterTagView()
            }
    }

    private func filteredTags() -> [LinkdingTagEntity] {
        return self.tagStore
            .filteredTags(nameFilter: self.tagSearchString, onlyUsed: self.onlyUsed)
            .sorted {
                let compareOrder = self.sortOrder == .ascending ? ComparisonResult.orderedAscending : ComparisonResult.orderedDescending

                return $0.name.compare($1.name, options: .caseInsensitive) == compareOrder
            }
    }
}
