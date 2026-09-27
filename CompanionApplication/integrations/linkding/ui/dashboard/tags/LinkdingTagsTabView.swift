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
    @State var favoriteGroupExpanded: Bool = true
    
    @Binding var openConfig: Bool
    
    var body: some View {
        NavigationSplitView(sidebar: {
            if self.syncHadError {
                Section() {
                    SyncErrorView(errorDetails: self.syncErrorMessage)
                }
            }
            List(selection: self.$selectedItem) {
                ForEach(self.buildMenu()) { item in
                    if let children = item.children {
                        Section(item.name, isExpanded: self.expandedBinding(for: item)) {
                            ForEach(children) { child in
                                self.menuItemRow(item: child)
                            }
                        }
                    } else {
                        self.menuItemRow(item: item)
                    }
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

    @ViewBuilder
    private func menuItemRow(item: TagViewMenuItem) -> some View {
        NavigationLink(value: item, label: {
            HStack {
                Image(systemName: item.tag?.favorite == true ? "star.fill" : "tag")
                Text(item.name)
                    .badge(item.badge ?? 0)
                    .lineLimit(1)
            }
        })
        .swipeActions(edge: .trailing) {
            if let tag = item.tag {
                Button(action: {
                    let repository = LinkdingTagRepository(tagStore: self.tagStore)
                    repository.setFavorite(tag: tag, favorite: !tag.favorite)
                }) {
                    Image(systemName: tag.favorite ? "star.slash" : "star")
                }
                .tint(.yellow)
            }
        }
    }

    private func expandedBinding(for folder: TagViewMenuItem) -> Binding<Bool> {
        return folder.name == "Favorites" ? self.$favoriteGroupExpanded : self.$tagGroupExpanded
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

        let favoriteTags = self.filteredTags()
            .filter { $0.favorite }
            .map {
                TagViewMenuItem(name: $0.name, type: .tag, badge: $0.bookmarks.count, tag: $0)
            }
        if !favoriteTags.isEmpty {
            menu.append(TagViewMenuItem(name: "Favorites", type: .folder, children: favoriteTags))
        }

        let tags = self.filteredTags()
            .filter { !$0.favorite }
            .map {
                TagViewMenuItem(name: $0.name, type: .tag, badge: $0.bookmarks.count, tag: $0)
            }
        menu.append(TagViewMenuItem(name: "Tags", type: .folder, children: tags))

        return menu
    }
}
