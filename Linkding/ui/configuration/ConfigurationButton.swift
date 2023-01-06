//
// ConfigurationButton.swift
// Created by Christian Wilhelm
//

import SwiftUI

struct ConfigurationButton: View {
    @State var configurationOpen: Bool = false
    @State var hasSettingsError: Bool = false
    @State var integrationSelection: String = "linkding"

    private let validator = LinkdingSettingsValidator()

    var body: some View {
        Button(action: {
            self.configurationOpen = true
        }, label: {
            Image(systemName: "gear")
            if (self.hasSettingsError) {
                Image(systemName: "exclamationmark")
                    .foregroundColor(.red)
            }
        })
            .sheet(isPresented: self.$configurationOpen, content: {
                NavigationView {
                    List {
                        // Copy of ConfigurationView structure
                        // TODO: Needs to be replaced with general solution how to include the general integration configuration
                        //       UI from the main app. This should not be implemented in each integration
                        Section() {
                            Picker("Select Bookmark Service", selection: self.$integrationSelection) {
                                Text("Linkding").tag("linkding")
                            }
                        }
                        LinkdingSettingsView()
                    }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    if (!validator.validateSettings()) {
                                        self.hasSettingsError = true
                                    } else {
                                        self.hasSettingsError = false
                                    }
                                    self.configurationOpen = false
                                }) {
                                    Text("Close")
                                }
                            }
                        }
                }
            })
            .onAppear() {
                if (!validator.validateSettings()) {
                    self.hasSettingsError = true
                }
            }
    }
}
