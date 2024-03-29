//
// BookmarkEditor.swift
// Created by Christian Wilhelm
//

import SwiftUI

struct BookmarkEditor: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var bookmarkStore: LinkdingBookmarkStore
    @EnvironmentObject var tagStore: LinkdingTagStore

    @ObservedObject var bookmark: LinkdingBookmarkEntity

    @State var url: String = ""
    @State var title: String = ""
    @State var description: String = ""
    @State var isArchived: Bool = false
    @State var unread: Bool = false
    @State var shared: Bool = false
    @State var tags = Set<LinkdingTagEntity>()

    @State var selectTagsOpen: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Bookmark") {
                    TextField(text: $url) {
                        Text("URL")
                    }
                    TextField(text: $title) {
                        Text(self.bookmark.websiteTitle ?? "Title")
                    }
                    TextField(text: $description) {
                        Text(self.bookmark.websiteDescription ?? "Description")
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
                if let urlObj = URL(string: self.url) {
                    ShareLink("Share bookmark", item: urlObj)
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
                .onAppear() {
                    self.url = self.bookmark.url
                    self.title = self.bookmark.title
                    self.description = self.bookmark.urlDescription
                    self.isArchived = self.bookmark.isArchived
                    self.unread = self.bookmark.unread
                    self.shared = self.bookmark.shared
                    self.tags = Set(self.bookmark.tagEntities.map { $0 })
                }
                .navigationBarTitle("Edit Bookmark")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            if (self.url != "") {
                                let repository = LinkdingBookmarkRepository(bookmarkStore: self.bookmarkStore, tagStore: self.tagStore)
                                let bookmark = repository.updateBookmark(bookmark: self.bookmark, url: self.url, title: self.title, description: self.description, isArchived: self.isArchived, unread: self.unread, shared: self.shared, tags: self.tags.map { $0.name })
                                let syncClient = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                                Task {
                                    try await syncClient.syncSingleBookmark(bookmark: bookmark)
                                }
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Image(systemName: "tray.and.arrow.down")
                        }
                    }
                }
                .sheet(isPresented: self.$selectTagsOpen) {
                    SelectTagsView(selectedTags: self.$tags)
                }
        }
    }
}
