//
// ConfigurationButton.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding

struct ConfigurationButton: View {
    @State var configurationOpen: Bool = false
    @State var hasSettingsError: Bool = false

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
                    ConfigurationView()
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
