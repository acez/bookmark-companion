//
// SyncErrorView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public struct SyncErrorView: View {
    var errorDetails: String?
    
    public var body: some View {
        VStack {
            Section() {
                ErrorView(
                    title: "Synchronization error.",
                    message: "Please check your URL and your Token in the configuration dialog.",
                    details: self.errorDetails
                )
            }
        }
    }
}

struct SyncErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            SyncErrorView()
        }
        Form {
            SyncErrorView(errorDetails: "Dummy Error Message")
        }
    }
}
