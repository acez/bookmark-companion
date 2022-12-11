//
// ShareBookmarkTagSelect.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding

struct ShareBookmarkTagSelect: View {
    @EnvironmentObject var tagStore: LinkdingTagStore
    @Environment(\.presentationMode) private var presentationMode

    @Binding var selectedTags: Set<String>

    var tagNames: [String] {
        get {
            return self.tagStore.tags.map { $0.name }
        }
    }

    var body: some View {
        NavigationView {
            List(tagNames, id: \.self, selection: $selectedTags) { name in
                Text(name)
            }
                .environment(\.editMode, .constant(EditMode.active))
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

