//
// LinkdingTagsTabView.swift
// Created by Christian Wilhelm
//

import SwiftUI

enum TagMenuItemType {
    case untagged
    case folder
    case tag
}

struct TagViewMenuItem: Identifiable, Hashable {
    var id: Self { self }
    var name: String
    var type: TagMenuItemType
    var badge: Int?
    var tag: LinkdingTagEntity?
    var children: [TagViewMenuItem]?
}

struct LinkdingTagsTabView: View {
    @EnvironmentObject var tagStore: LinkdingTagStore
    @EnvironmentObject var bookmarkStore: LinkdingBookmarkStore

    @AppStorage(LinkdingSettingKeys.syncHadError.rawValue, store: AppStorageSupport.shared.sharedStore) var syncHadError: Bool = false
    @AppStorage(LinkdingSettingKeys.syncErrorMessage.rawValue, store: AppStorageSupport.shared.sharedStore) var syncErrorMessage: String = ""
    @AppStorage(LinkdingSettingKeys.tagFilterOnlyUsed.rawValue, store: AppStorageSupport.shared.sharedStore) var onlyUsed: Bool = false
    
    @AppStorage(LinkdingSettingKeys.tagSortOrder.rawValue, store: AppStorageSupport.shared.sharedStore) var sortOrder: SortOrder = .ascending

    @State var selectedItem: TagViewMenuItem? = nil
    @State var tagSearchString: String = ""
    @State var createSheetOpen: Bool = false
    @State var filterSheetOpen: Bool = false

    @State var tagGroupExpanded: Bool = true
    
    @Binding var openConfig: Bool
    
    var body: some View {
        NavigationSplitView(sidebar: {
            if self.syncHadError {
                Section() {
                    SyncErrorView(errorDetails: self.syncErrorMessage)
                }
            }
            List(self.buildMenu(), children: \.children, selection: self.$selectedItem) { item in
                if item.children != nil {
                    HStack {
                        Image(systemName: "folder")
                        Text(item.name)
                            .lineLimit(1)
                    }
                } else {
                    NavigationLink(value: item, label: {
                        HStack {
                            Image(systemName: "tag")
                            Text(item.name)
                                .badge(item.badge ?? 0)
                                .lineLimit(1)
                        }
                    })
                }
            }
            .listStyle(.sidebar)
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
        }, detail: {
            if selectedItem != nil {
                if self.selectedItem!.type == .tag {
                    LinkdingTagBookmarksView(tag: self.selectedItem!.tag, title: self.selectedItem!.name)
                }
                if self.selectedItem!.type == .untagged {
                    LinkdingTagBookmarksView(tag: self.selectedItem!.tag, title: self.selectedItem!.name)
                }
            } else {
                Text("Please select a tag")
            }
        })
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
    
    private func buildMenu() -> [TagViewMenuItem] {
        var menu: [TagViewMenuItem] = []
        
        menu.append(TagViewMenuItem(name: "Untagged", type: .untagged, badge: self.bookmarkStore.untagged.count))
        
        let tags = self.filteredTags().map {
            TagViewMenuItem(name: $0.name, type: .tag, badge: $0.bookmarks.count, tag: $0)
        }
        menu.append(TagViewMenuItem(name: "Tags", type: .folder, children: tags))
        
        return menu
    }
}
