//
// ShareBookmarkCreate.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding
import Shared

struct ShareBookmarkCreate: View {
    var bookmarkStore: LinkdingBookmarkStore = LinkdingBookmarkStore()
    var tagStore: LinkdingTagStore = LinkdingTagStore()

    @AppStorage(LinkdingSettingKeys.createBookmarkDefaultArchived.rawValue, store: AppStorageSupport.shared.sharedStore) var defaultArchived: Bool = false
    @AppStorage(LinkdingSettingKeys.createBookmarkDefaultUnread.rawValue, store: AppStorageSupport.shared.sharedStore) var defaultUnread: Bool = false
    @AppStorage(LinkdingSettingKeys.createBookmarkDefaultShared.rawValue, store: AppStorageSupport.shared.sharedStore) var defaultShared: Bool = false

    @State var url: String = ""
    @State var title: String = ""
    @State var description: String = ""
    @State var isArchived: Bool = false
    @State var unread: Bool = false
    @State var shared: Bool = false
    @State var tags = Set<LinkdingTagEntity>()

    @State var selectTagsOpen: Bool = false
    @State var linkdingAvailable: Bool = false

    var onClose: @MainActor () -> ()

    var body: some View {
        NavigationView {
            Form {
                Section(
                    content: {
                        TextField(text: $url) {
                            Text("URL")
                        }
                        TextField(text: $title) {
                            Text("Title")
                        }
                        TextField(text: $description) {
                            Text("Description")
                        }
                    },
                    header: {
                        Text( "Bookmark")
                    },
                    footer: {
                        if !self.linkdingAvailable {
                            Text("Linkding backend is not available. Bookmark is stored on your device.")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                )
                Section("Flags") {
                    Toggle(isOn: $unread) {
                        Text("Unread")
                    }
                    Toggle(isOn: $shared) {
                        Text("Shared")
                    }
                }
                Section(content: {
                    if (self.tags.count > 0) {
                        ForEach(self.tags.map { $0 }) { tag in
                            Text(tag.name)
                        }
                    } else {
                        Text("No tags selected")
                    }
                }, header: {
                    HStack {
                        Text("Tags")
                        Spacer()
                        Button(action: {
                            self.selectTagsOpen = true
                        }) {
                            Text("Select tags")
                        }
                            .font(.caption)
                            .buttonStyle(.borderless)
                    }
                })
            }
                .navigationBarTitle("Create Bookmark")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            if (self.url != "") {
                                Task {
                                    let repository = LinkdingBookmarkRepository(bookmarkStore: self.bookmarkStore, tagStore: self.tagStore)
                                    let createdBookmark = repository.createNewBookmark(url: self.url, title: self.title, description: self.description, isArchived: self.isArchived, unread: self.unread, shared: self.shared, tags: self.tags.map{ $0.name })
                                    if self.linkdingAvailable {
                                        let sync = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                                        do {
                                            try await sync.syncSingleBookmark(bookmark: createdBookmark)
                                        } catch (_) {
                                            self.onClose()
                                        }
                                    }
                                    self.onClose()
                                }
                            }
                        }) {
                            Image(systemName: "tray.and.arrow.down")
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: {
                            self.onClose()
                        }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .sheet(isPresented: self.$selectTagsOpen) {
                    ShareBookmarkTagSelect(selectedTags: self.$tags)
                        .environmentObject(self.tagStore)
                }
                .onAppear() {
                    LinkdingPersistenceController.shared.setViewContextData(name: "viewContext", author: "ShareExtension")

                    self.isArchived = self.defaultArchived
                    self.unread = self.defaultUnread
                    self.shared = self.defaultShared
                    
                    let syncClient = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                    Task {
                        if await syncClient.isBackendAvailable() {
                            self.linkdingAvailable = true
                        } else {
                            self.linkdingAvailable = false
                        }
                    }
                }
        }
            .navigationViewStyle(.stack)
    }
}
