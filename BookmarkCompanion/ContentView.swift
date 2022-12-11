//
// ContentView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import CoreData
import Linkding

struct ContentView: View {
    @AppStorage(LinkdingSettingKeys.configComplete.rawValue, store: AppStorageSupport.shared.sharedStore) var configComplete: Bool = false

    var body: some View {
        if (self.configComplete) {
            LinkdingDashboardView()
        } else {
            InitialConfiguration()
        }
    }
}
