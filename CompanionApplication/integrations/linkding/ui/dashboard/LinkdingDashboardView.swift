//
// LinkdingDashboardView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public struct LinkdingDashboardView: View, BaseIntegrationDashboard {
    var openConfig: Binding<Bool>
    
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = LinkdingPersistenceController.shared

    var tagStore: LinkdingTagStore = LinkdingTagStore()
    var bookmarkStore: LinkdingBookmarkStore = LinkdingBookmarkStore()
    
    public init(openConfig: Binding<Bool>) {
        self.openConfig = openConfig
    }
    
    public var body: some View {
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
