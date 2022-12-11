//
// InitialConfiguration.swift
// Created by Christian Wilhelm
//
import SwiftUI
import Linkding

struct InitialConfiguration: View {
    @State var showSettingsError: Bool = false
    @AppStorage(LinkdingSettingKeys.configComplete.rawValue, store: AppStorageSupport.shared.sharedStore) var configComplete: Bool = false

    var body: some View {
        NavigationView {
            ConfigurationView()
                .navigationTitle("Setup")
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            let validator = LinkdingSettingsValidator()
                            if (validator.validateSettings()) {
                                self.configComplete = true
                            } else {
                                self.showSettingsError = true
                            }
                        }) {
                            Text("Save")
                        }
                    }
                }
                .alert(isPresented: self.$showSettingsError) {
                    Alert(title: Text("Invalid Settings. Please always set URL and Token."))
                }
        }
            .navigationViewStyle(.stack)
    }
}
