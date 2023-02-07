//
// SelectTagsView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Shared

struct SelectTagsView: View {
    @EnvironmentObject var tagStore: LinkdingTagStore
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismissSearch) private var dismissSearch

    @Binding var selectedTags: Set<UUID>

    var body: some View {
        NavigationView {
            SelectOrCreateList(
                items: self.tagStore.tags,
                selectedItems: self.$selectedTags,
                createActionHandler: { tagName in
                    let repository = LinkdingTagRepository(tagStore: self.tagStore)
                    let createdTag = repository.createTag(tag: TagModel(name: tagName))
                    self.selectedTags.insert(createdTag.internalId)
                    dismissSearch()
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

extension LinkdingTagEntity: SelectOrCreateItemListProvider {
    public func getItemText() -> String {
        return self.name
    }
}
