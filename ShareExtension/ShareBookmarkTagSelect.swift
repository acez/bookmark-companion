//
// ShareBookmarkTagSelect.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding
import Shared

struct ShareBookmarkTagSelect: View {
    @EnvironmentObject var tagStore: LinkdingTagStore
    @Environment(\.presentationMode) private var presentationMode

    @Binding var selectedTags: Set<UUID>

    var body: some View {
        NavigationView {
            SelectOrCreateList(
                items: self.tagStore.tags,
                selectedItems: self.$selectedTags,
                createActionHandler: {tagName in
                    let repository = LinkdingTagRepository(tagStore: self.tagStore)
                    let createdTag = repository.createTag(tag: TagModel(name: tagName))
                    self.selectedTags.insert(createdTag.internalId)
                }
            )
            .navigationBarTitle("Select tags")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                    }
                }
            }
        }
    }
}

