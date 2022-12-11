//
// ShareBookmarkContainerView.swift
// Created by Christian Wilhelm
//

import SwiftUI
import Linkding

struct ShareBookmarkContainerView: View {
    @AppStorage(LinkdingSettingKeys.configComplete.rawValue, store: AppStorageSupport.shared.sharedStore) var configComplete: Bool = false
    
    var onClose: @MainActor () -> ()
    var url: String
    
    var body: some View {
        if (self.configComplete) {
            ShareBookmarkCreate(url: url, onClose: onClose)
        } else {
            Text("Please setup BookmarkCompanion first.")
        }
    }
}
