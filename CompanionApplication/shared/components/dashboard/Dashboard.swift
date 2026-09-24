//
//  Dashboard.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct Dashboard<ID: Hashable, CreateView: View>: View {
    var bookmarkStore: any BookmarkStore<ID>
    var tagStore: any TagStore<ID>
    var syncService: SyncService

    var title: String

    @ViewBuilder var createBookmarkView: (Tag<ID>?) -> CreateView

    @State var openConfig: Bool = false
    @State private var createBookmarkOpen: Bool = false
    @State private var searchText: String = ""
    @State private var tagsRefresh: Int = 0

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    LazyVGrid(columns: self.columns, spacing: 14) {
                        NavigationLink(destination: BookmarkListViewV2(title: "All bookmarks", bookmarks: self.allBookmarks(), createBookmarkView: { self.createBookmarkView(nil) })) {
                            DashboardTile(title: "All bookmarks", count: self.allBookmarksCount(), color: .blue, iconName: "bookmark.fill")
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: BookmarkListViewV2(title: "Unread bookmarks", bookmarks: self.unreadBookmarks(), createBookmarkView: { self.createBookmarkView(nil) })) {
                            DashboardTile(title: "Unread bookmarks", count: self.unreadBookmarksCount(), color: .orange, iconName: "tray.full.fill")
                        }
                        .buttonStyle(.plain)
                    }

                    let _ = self.tagsRefresh
                    let tags = self.tagStore.filter(text: self.searchText.isEmpty ? nil : self.searchText)
                    let favoriteTags = tags.filter { $0.favorite }
                    let otherTags = tags.filter { !$0.favorite }

                    if !favoriteTags.isEmpty {
                        self.tagSection(title: "Favorites", tags: favoriteTags)
                    }
                    if !otherTags.isEmpty {
                        self.tagSection(title: "Tags", tags: otherTags)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(self.title)
            .searchable(text: self.$searchText, prompt: "Search tags")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    ConfigurationButton(actionHandler: {
                        self.openConfig = true
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.createBookmarkOpen = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: self.$openConfig) {
                ConfigurationSheet()
            }
            .sheet(isPresented: self.$createBookmarkOpen) {
                self.createBookmarkView(nil)
            }
            .refreshable {
                await self.syncService.runFullSync()
            }
        }
    }
    
    @ViewBuilder
    private func tagSection(title: String, tags: [Tag<ID>]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.weight(.bold))

            VStack(spacing: 10) {
                ForEach(tags) { tag in
                    NavigationLink(destination: BookmarkListViewV2(
                        title: tag.name,
                        bookmarks: self.bookmarkStore.byTag(tag: tag),
                        isFavorite: tag.favorite,
                        favoriteAction: { favorite in
                            self.tagStore.setFavorite(tag: tag, favorite: favorite)
                            self.tagsRefresh += 1
                        },
                        createBookmarkView: { self.createBookmarkView(tag) }
                    )) {
                        DashboardTagListItem(
                            tagName: tag.name,
                            tagBookmarkCount: self.tagBookmarkCount(tag: tag),
                            isFavorite: tag.favorite,
                            favoriteAction: {
                                self.tagStore.setFavorite(tag: tag, favorite: !tag.favorite)
                                self.tagsRefresh += 1
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    func allBookmarks() -> [Bookmark<ID>] {
        return self.bookmarkStore.filter(text: nil, filter: .all)
    }
    
    func allBookmarksCount() -> Int {
        return self.allBookmarks().count
    }
    
    func unreadBookmarks() -> [Bookmark<ID>] {
        return self.bookmarkStore.filter(text: nil, filter: .unread)
    }
    
    func unreadBookmarksCount() -> Int {
        return self.unreadBookmarks().count
    }
    
    func tagBookmarkCount(tag: Tag<ID>) -> Int {
        return self.bookmarkStore
            .byTag(tag: tag)
            .count
    }
}

#Preview("Dashboard") {
    Dashboard(
        bookmarkStore: PreviewBookmarkStore(),
        tagStore: PreviewTagStore(),
        syncService: PreviewSyncService(),
        title: "Preview",
        createBookmarkView: { _ in Text("Create bookmark") }
    )
}

private struct PreviewBookmarkStore: BookmarkStore {
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

private struct PreviewTagStore: TagStore {
    typealias ID = UUID
    
    func filter(text: String?) -> [Tag<UUID>] {
        return [
            Tag(id: UUID(), name: "tag-1", favorite: true),
            Tag(id: UUID(), name: "tag-2"),
            Tag(id: UUID(), name: "tag-3")
        ]
    }

    func setFavorite(tag: Tag<UUID>, favorite: Bool) {}
}

private struct PreviewSyncService: SyncService {
    func runFullSync() {}
}
