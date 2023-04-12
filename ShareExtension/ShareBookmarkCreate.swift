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
    @State var displayTitle: String = ""
    @State var description: String = ""
    @State var isArchived: Bool = false
    @State var unread: Bool = false
    @State var shared: Bool = false
    @State var tags = Set<LinkdingTagEntity>()
    @State var bookmark: LinkdingBookmarkEntity?

    @State var selectTagsOpen: Bool = false
    @State var linkdingAvailable: Bool = false
    @State var requestInProgress: Bool = false

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
                            Text(self.bookmark?.websiteTitle ?? "Title")
                        }
                        TextField(text: $description) {
                            Text(self.bookmark?.websiteDescription ?? "Description")
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
                        if self.requestInProgress {
                            ProgressView()
                        } else {
                            Button(action: {
                                if (self.url != "") {
                                    Task {
                                        self.requestInProgress = true
                                        let repository = LinkdingBookmarkRepository(bookmarkStore: self.bookmarkStore, tagStore: self.tagStore)
                                        let syncBookmark = self.bookmark != nil ?
                                            repository.updateBookmark(bookmark: self.bookmark!, url: self.url, title: self.title, description: self.description, isArchived: self.isArchived, unread: self.unread, shared: self.shared, tags: self.tags.map { $0.name }) :
                                            repository.createNewBookmark(url: self.url, title: self.title, description: self.description, isArchived: self.isArchived, unread: self.unread, shared: self.shared, tags: self.tags.map{ $0.name })
                                        if self.linkdingAvailable {
                                            let sync = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                                            do {
                                                try await sync.syncSingleBookmark(bookmark: syncBookmark)
                                            } catch (_) {
                                                self.requestInProgress = false
                                                self.onClose()
                                            }
                                        }
                                        self.requestInProgress = false
                                        self.onClose()
                                    }
                                }
                            }) {
                                Image(systemName: "tray.and.arrow.down")
                            }
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
                    
                    if let found = self.bookmarkStore.getByUrl(url: self.url) {
                        self.bookmark = found
                        self.title = found.title
                        self.description = found.urlDescription
                        self.isArchived = found.isArchived
                        self.unread = found.unread
                        self.shared = found.shared
                        self.tags = Set(self.tagStore.getByNameList(names: found.tagNames))
                    } else {
                        self.isArchived = self.defaultArchived
                        self.unread = self.defaultUnread
                        self.shared = self.defaultShared
                    }

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
