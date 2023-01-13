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

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("Filter") {
                        Toggle("Only show unread", isOn: self.$showUnread)
                    }
                }
            }
                .navigationTitle("Settings")
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
