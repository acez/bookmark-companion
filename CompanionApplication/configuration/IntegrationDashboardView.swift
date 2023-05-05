//
//  IntegrationDashboardView.swift
//  BookmarkCompanion
//
//  Created by Christian Wilhelm on 06.01.23.
//

import SwiftUI

struct IntegrationDashboardView: View {
    @State var openConfig: Bool = false
    
    var body: some View {
        LinkdingDashboardView(openConfig: self.$openConfig)
            .sheet(isPresented: self.$openConfig, content: {
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
            })
    }
}

struct IntegrationDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        IntegrationDashboardView()
    }
}
