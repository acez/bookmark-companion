//
// LinkdingDashboardView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public struct LinkdingDashboardView: View, BaseIntegrationDashboard {
    @AppStorage(SharedSettingKeys.useExperimentalDashboard.rawValue, store: AppStorageSupport.shared.sharedStore) var useExperimentalDashboard: Bool = false
    
    var openConfig: Binding<Bool>
    
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = LinkdingPersistenceController.shared

    var tagStore: LinkdingTagStore = LinkdingTagStore()
    var bookmarkStore: LinkdingBookmarkStore = LinkdingBookmarkStore()
    
    public init(openConfig: Binding<Bool>) {
        self.openConfig = openConfig
    }
    
    var selectedView: some View {
        ZStack {
            if self.useExperimentalDashboard {
                Dashboard(bookmarkStore: self, tagStore: self, syncService: self, title: "Linkding")
            } else {
                TabView {
                    LinkdingBookmarkTabView(openConfig: self.openConfig)
                        .tabItem {
                            Image(systemName: "bookmark")
                            Text("Bookmarks")
                        }
                    LinkdingTagsTabView(openConfig: self.openConfig)
                        .tabItem {
                            Image(systemName: "tag")
                            Text("Tags")
                        }
                }
            }
        }
    }
    
    public var body: some View {
        self.selectedView
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.managedObjectContext, persistenceController.viewContext)
            .environmentObject(self.tagStore)
            .environmentObject(self.bookmarkStore)
            .onAppear() {
                LinkdingPersistenceController.shared.setViewContextData(name: "viewContext", author: "BookmarkCompanion")
                
                // Migration of linkding token access to app group
                AccessTokenMigrationToAppGroup().migrate()

                Task {
                    let sync = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                    try await sync.sync()
                }
            }
            .onChange(of: scenePhase, perform: { newPhase in
                if newPhase == .active {
                    let sync = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                    Task {
                        try await sync.sync()
                    }
                }
            })
    }
}

extension LinkdingDashboardView: BookmarkStore {
    public typealias ID = UUID

    public func filter(text: String?, filter: BookmarkStoreFilter?) -> [Bookmark<UUID>] {
        let unreadOnly = filter == .unread ? true : false
        return self.bookmarkStore
            .filtered(showArchived: false, showUnreadOnly: unreadOnly, filterText: text ?? "")
            .map { Bookmark(id: $0.internalId, title: $0.title, url: $0.url, tags: []) }
    }
    
    public func byTag(tag: Tag<UUID>) -> [Bookmark<UUID>] {
        return []
    }
}

extension LinkdingDashboardView: TagStore {
    public func filter(text: String?) -> [Tag<UUID>] {
        return self.tagStore
            .usedTags
            .map { Tag(id: $0.id, name: $0.name) }
    }
}

extension LinkdingDashboardView: SyncService {
    func runFullSync() async {
        let sync = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
        try? await sync.sync()
    }
}
