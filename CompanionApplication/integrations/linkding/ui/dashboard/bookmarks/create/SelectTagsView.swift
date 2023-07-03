//
// SelectTagsView.swift
// Created by Christian Wilhelm
//

import SwiftUI

struct SelectTagsView: View {
    @EnvironmentObject var tagStore: LinkdingTagStore
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismissSearch) private var dismissSearch

    @Binding var selectedTags: Set<LinkdingTagEntity>

    var body: some View {
        NavigationStack {
            CommonSelectListView(
                items: self.tagStore.tags,
                selectedItems: self.$selectedTags,
                createNotFoundHandler: self
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

extension SelectTagsView: CreateNotFoundItemHandler {
    func createItem(text: String) {
        let repository = LinkdingTagRepository(tagStore: self.tagStore)
        let createdTag = repository.createTag(tag: TagModel(name: text))
        self.selectedTags.insert(createdTag)
        self.dismissSearch()
    }
}

extension LinkdingTagEntity: CommonListItem {
    public func getDisplayText() -> String {
        return self.name
    }
}
