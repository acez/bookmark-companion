//
// CreateTagView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding

struct CreateTagView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @EnvironmentObject private var tagStore: LinkdingTagStore
    @EnvironmentObject private var bookmarkStore: LinkdingBookmarkStore
    
    @State var name: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField(text: self.$name) {
                    Text("Name")
                }
            }
            .navigationTitle("Create tag")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        if self.name != "" {
                            let repository = LinkdingTagRepository(tagStore: self.tagStore)
                            let tag = repository.createTag(tag: TagModel(name: self.name))
                            let syncClient = LinkdingSyncClient(tagStore: self.tagStore, bookmarkStore: self.bookmarkStore)
                            Task {
                                try await syncClient.syncSingleTag(tag: tag)
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }) {
                        Image(systemName: "tray.and.arrow.down")
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
        }
    }
}
