//
//  MainView.swift
//  CompanionApplication
//
//  Created by Christian Wilhelm on 06.05.23.
//

import SwiftUI

public struct MainView: View {
    @AppStorage(LinkdingSettingKeys.configComplete.rawValue, store: AppStorageSupport.shared.sharedStore) var configComplete: Bool = false
    
    public init() {
    }
    
    public var body: some View {
        if (self.configComplete) {
            IntegrationDashboardView()
        } else {
            InitialConfiguration()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
