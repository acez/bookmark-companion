//
// FilterTagView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Shared

struct FilterTagView: View {
    @Environment(\.presentationMode) private var presentationMode

    @AppStorage(LinkdingSettingKeys.tagFilterOnlyUsed.rawValue, store: AppStorageSupport.shared.sharedStore) var onlyUsed: Bool = false
    @AppStorage(LinkdingSettingKeys.tagSortOrder.rawValue, store: AppStorageSupport.shared.sharedStore) var sortOrder: SortOrder = .ascending

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
