//
// InitialConfiguration.swift
// Created by Christian Wilhelm
//
import SwiftUI
import CompanionApplication

struct InitialConfiguration: View {
    @State var showSettingsError: Bool = false
    @AppStorage(LinkdingSettingKeys.configComplete.rawValue, store: AppStorageSupport.shared.sharedStore) var configComplete: Bool = false

    var body: some View {
        NavigationView {
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
                .alert(isPresented: self.$showSettingsError) {
                    Alert(title: Text("Invalid Settings. Please always set URL and Token."))
                }
        }
            .navigationViewStyle(.stack)
    }
}

struct InitialConfiguration_Previews: PreviewProvider {
    static var previews: some View {
        InitialConfiguration()
    }
}
