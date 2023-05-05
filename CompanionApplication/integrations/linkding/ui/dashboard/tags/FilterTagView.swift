//
// FilterTagView.swift
// Created by Christian Wilhelm
//

import SwiftUI

struct FilterTagView: View {
    @Environment(\.presentationMode) private var presentationMode

    @AppStorage(LinkdingSettingKeys.tagFilterOnlyUsed.rawValue, store: AppStorageSupport.shared.sharedStore) var onlyUsed: Bool = false
    @AppStorage(LinkdingSettingKeys.tagSortOrder.rawValue, store: AppStorageSupport.shared.sharedStore) var sortOrder: SortOrder = .ascending
    @AppStorage(LinkdingSettingKeys.tagViewBookmarkDescription.rawValue, store: AppStorageSupport.shared.sharedStore) var viewBookmarkDescription: Bool = false
    @AppStorage(LinkdingSettingKeys.tagViewBookmarkTags.rawValue, store: AppStorageSupport.shared.sharedStore) var viewBookmarkTags: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("Filter") {
                        Toggle("Hide unused tags", isOn: self.$onlyUsed)
                    }
                    Section("Sort") {
                        Picker("Sort order", selection: self.$sortOrder) {
                            Text("Ascending").tag(SortOrder.ascending)
                            Text("Descending").tag(SortOrder.descending)
                        }
                    }
                    Section("View") {
                        Toggle("Show bookmark description", isOn: self.$viewBookmarkDescription)
                        Toggle("Show bookmark tags", isOn: self.$viewBookmarkTags)
                    }
                }
            }
            .navigationTitle("Tag Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
