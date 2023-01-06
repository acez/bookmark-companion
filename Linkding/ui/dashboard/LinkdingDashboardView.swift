//
// LinkdingDashboardView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public struct LinkdingDashboardView: View {
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = LinkdingPersistenceController.shared

    var tagStore: LinkdingTagStore = LinkdingTagStore()
    var bookmarkStore: LinkdingBookmarkStore = LinkdingBookmarkStore()
    
    public init() {
    }

    public var body: some View {
        TabView {
            LinkdingBookmarkTabView()
                .tabItem {
                    Image(systemName: "bookmark")
                    Text("Bookmarks")
                }
            LinkdingTagsTabView()
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
