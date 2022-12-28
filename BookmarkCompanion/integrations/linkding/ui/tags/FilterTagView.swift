//
// FilterTagView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding
import Shared

struct FilterTagView: View {
    @Environment(\.presentationMode) private var presentationMode

    @AppStorage(LinkdingSettingKeys.tagFilterOnlyUsed.rawValue, store: AppStorageSupport.shared.sharedStore) var onlyUsed: Bool = false

    @State var selection: Set<String> = []
    
    @State private var filterOptions = [
        FilterOption(id: "onlyused", text: "Hide unused tags")
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
                        self.onlyUsed = self.selection.contains("onlyused")
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Apply")
                    }
                }
            }
            .onAppear() {
                if (self.onlyUsed) {
                    self.selection.update(with: "onlyused")
                }
            }
        }
    }
}
