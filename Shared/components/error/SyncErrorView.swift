//
// SyncErrorView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public struct SyncErrorView: View {
    public var body: some View {
        VStack {
            Section() {
                Text("Synchronization error.")
                    .foregroundColor(.red)
                Text("Please check your URL and your Token in the configuration dialog.")
            }
        }
    }
}
