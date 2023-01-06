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
    @State var selectedIntegration: BookmarkIntegrations = .linkding

    var body: some View {
        VStack {
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
        }
    }
}
