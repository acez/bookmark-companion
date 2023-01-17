//
// LinkdingBookmarkTabFilterView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Shared

struct LinkdingBookmarkTabSettingsView: View {
    @Environment(\.presentationMode) private var presentationMode

    @AppStorage(LinkdingSettingKeys.bookmarkFilterArchived.rawValue, store: AppStorageSupport.shared.sharedStore) var showArchived: Bool = false
    @AppStorage(LinkdingSettingKeys.bookmarkFilterUnread.rawValue, store: AppStorageSupport.shared.sharedStore) var showUnread: Bool = false
    @AppStorage(LinkdingSettingKeys.bookmarkSortField.rawValue, store: AppStorageSupport.shared.sharedStore)  var sortField: SortField = .url
    @AppStorage(LinkdingSettingKeys.bookmarkSortOrder.rawValue, store: AppStorageSupport.shared.sharedStore) var sortOrder: SortOrder = .ascending
    @AppStorage(LinkdingSettingKeys.bookmarkViewDescription.rawValue, store: AppStorageSupport.shared.sharedStore) var viewDescription: Bool = true
    @AppStorage(LinkdingSettingKeys.bookmarkViewTags.rawValue, store: AppStorageSupport.shared.sharedStore) var viewTags: Bool = true
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("Filter") {
                        Toggle("Only show unread", isOn: self.$showUnread)
                    }
                    Section("Sort") {
                        Picker("Sort by field", selection: self.$sortField) {
                            Text("URL").tag(SortField.url)
                            Text("Title").tag(SortField.title)
                            Text("Description").tag(SortField.description)
                            Text("Date added").tag(SortField.dateAdded)
                            Text("Date modified").tag(SortField.dateModified)
                        }
                        Picker("Sort order", selection: self.$sortOrder) {
                            Text("Ascending").tag(SortOrder.ascending)
                            Text("Descending").tag(SortOrder.descending)
                        }
                    }
                    Section("View") {
                        Toggle("Show description", isOn: self.$viewDescription)
                        Toggle("Show tags", isOn: self.$viewTags)
                    }
                }
            }
                .navigationTitle("Bookmark Settings")
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
