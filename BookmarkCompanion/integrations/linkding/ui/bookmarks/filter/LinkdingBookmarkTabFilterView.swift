//
// LinkdingBookmarkTabFilterView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding

struct FilterOption {
    var id: String
    var text: String
}

struct LinkdingBookmarkTabFilterView: View {
    @Environment(\.presentationMode) private var presentationMode

    @AppStorage(LinkdingSettingKeys.bookmarkFilterArchived.rawValue, store: AppStorageSupport.shared.sharedStore) var showArchived: Bool = false
    @AppStorage(LinkdingSettingKeys.bookmarkFilterUnread.rawValue, store: AppStorageSupport.shared.sharedStore) var showUnread: Bool = false

    @State var selection: Set<String> = []

    private var filterOptions = [
        FilterOption(id: "unread", text: "Only show unread")
    ]

    var body: some View {
        NavigationView {
            VStack {
                List(self.filterOptions, id: \.id, selection: self.$selection) { option in
                    Text(option.text)
                }
                    .environment(\.editMode, .constant(EditMode.active))
            }
                .navigationTitle("Filter options")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.showArchived = self.selection.contains("archived")
                            self.showUnread = self.selection.contains("unread")
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Apply")
                        }
                    }
                }
                .onAppear() {
                    if (self.showArchived) {
                        self.selection.update(with: "archived")
                    }
                    if (self.showUnread) {
                        self.selection.update(with: "unread")
                    }
                }
        }
    }
}
