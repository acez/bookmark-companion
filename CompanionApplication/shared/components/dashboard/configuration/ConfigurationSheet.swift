//
//  ConfigurationSheet.swift
//  Created by Christian Wilhelm
//

import SwiftUI

struct ConfigurationSheet: View {
    var body: some View {
        NavigationView {
            ConfigurationView(
                dismissToolbarItem: {
                    Text("Close")
                }, dismissHandler: {
                    return true
                }
            )
            .navigationTitle("Configuration")
        }
    }
}

struct ConfigurationSheet_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationSheet()
    }
}
