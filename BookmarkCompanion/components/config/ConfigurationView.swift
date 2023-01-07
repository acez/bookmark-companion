//
// ConfigurationView.swift
// Created by Christian Wilhelm
//
import SwiftUI
import Linkding

enum BookmarkIntegrations {
    case linkding
}

struct ConfigurationView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State var selectedIntegration: BookmarkIntegrations = .linkding
    @State var hasSettingsError: Bool = false
    @State var integrationSelection: String = "linkding"
    
    private let validator = LinkdingSettingsValidator()

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
        }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if (!validator.validateSettings()) {
                            self.hasSettingsError = true
                        } else {
                            self.hasSettingsError = false
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                    }
                }
            }
    }
}
