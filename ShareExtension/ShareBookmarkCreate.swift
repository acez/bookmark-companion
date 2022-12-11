//
// ShareBookmarkCreate.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding

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
    @State var tags = Set<String>()

    @State var selectTagsOpen: Bool = false

    var onClose: @MainActor () -> ()

    var body: some View {
        NavigationView {
            Form {
                Section("Bookmark") {
                    TextField(text: $url) {
                        Text("URL")
                    }
                    TextField(text: $title) {
                        Text("Title")
                    }
                    TextField(text: $description) {
                        Text("Description")
                    }
                }
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
                        ForEach(self.tags.map { $0 }, id: \.self) { tag in
                            Text(tag)
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
                                let repository = LinkdingBookmarkRepository(bookmarkStore: self.bookmarkStore, tagStore: self.tagStore)
                                _ = repository.createNewBookmark(url: self.url, title: self.title, description: self.description, isArchived: self.isArchived, unread: self.unread, shared: self.shared, tags: self.tags.map{ $0 })
                                self.onClose()
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
                }
        }
            .navigationViewStyle(.stack)
    }
}
