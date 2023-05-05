//
// LinkdingCreateBookmarkView.swift
// Created by Christian Wilhelm
//

import SwiftUI

struct LinkdingCreateBookmarkView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var bookmarkStore: LinkdingBookmarkStore
    @EnvironmentObject var tagStore: LinkdingTagStore

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
    @State var requestInProgress: Bool = false
    
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
                        if self.requestInProgress {
                            ProgressView()
                        } else {
                            Button(action: {
                                if (self.url != "") {
                                    self.requestInProgress = true
                                     let repository = LinkdingBookmarkRepository(bookmarkStore: self.bookmarkStore, tagStore: self.tagStore)
                                     let bookmark = repository.createNewBookmark(url: self.url, title: self.title, description: self.description, isArchived: self.isArchived, unread: self.unread, shared: self.shared, tags: self.tags.map { $0.name })
                                     let syncClient = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                                     Task {
                                         try await syncClient.syncSingleBookmark(bookmark: bookmark)
                                         self.requestInProgress = false
                                         self.presentationMode.wrappedValue.dismiss()
                                     }
                                }
                            }) {
                                Image(systemName: "tray.and.arrow.down")
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .sheet(isPresented: self.$selectTagsOpen) {
                    SelectTagsView(selectedTags: self.$tags)
                }
                .onAppear() {
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
    }
}
