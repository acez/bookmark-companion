//
// ConfigurationView.swift
// Created by Christian Wilhelm
//
import SwiftUI

enum BookmarkIntegrations {
    case linkding
}

struct ConfigurationView<DismissToolbarItem: View>: View {
    @AppStorage(SharedSettingKeys.useInAppBrowser.rawValue, store: AppStorageSupport.shared.sharedStore) var useInAppBrowser: Bool = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State var selectedIntegration: BookmarkIntegrations = .linkding
    @State var hasSettingsError: Bool = false
    @State var integrationSelection: String = "linkding"
    
    private let validator = LinkdingSettingsValidator()
    
    @ViewBuilder var dismissToolbarItem: () -> DismissToolbarItem
    var dismissHandler: () -> Bool

    var body: some View {
        List {
            Section() {
                Picker("Select Bookmark Service", selection: self.$selectedIntegration) {
                    Text("Linkding").tag(BookmarkIntegrations.linkding)
                }
            }
            switch self.selectedIntegration {
            case .linkding:
                LinkdingSettingsView()
            }
            Section("Global") {
                Toggle("Use In-App Browser", isOn: self.$useInAppBrowser)
            }
        }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let success = self.dismissHandler()
                        if success {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        self.dismissToolbarItem()
                    }
                }
            }
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConfigurationView(dismissToolbarItem: {
                Text("Close")
            }, dismissHandler: {
                return true
            })
        }
    }
}
