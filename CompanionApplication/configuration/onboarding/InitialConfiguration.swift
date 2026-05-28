//
// InitialConfiguration.swift
// Created by Christian Wilhelm
//
import SwiftUI

struct InitialConfiguration: View {
    @State var showSettingsError: Bool = false
    @AppStorage(LinkdingSettingKeys.configComplete.rawValue, store: AppStorageSupport.shared.sharedStore) var configComplete: Bool = false

    var body: some View {
        NavigationStack {
            ConfigurationView(
                dismissToolbarItem: {
                    Text("Save")
                }, dismissHandler: {
                    let validator = LinkdingSettingsValidator()
                    if (validator.validateSettings()) {
                        self.configComplete = true
                        return true
                    } else {
                        self.showSettingsError = true
                        return false
                    }
                }
            )
                .navigationTitle("Setup")
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .alert("Invalid Settings", isPresented: self.$showSettingsError) {
                    Button("OK") { }
                } message: {
                    Text("Please always set URL and Token.")
                }
        }
    }
}

#Preview {
    InitialConfiguration()
}
