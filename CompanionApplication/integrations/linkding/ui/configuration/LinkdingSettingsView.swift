//
// LinkdingSettingsView.swift
// Created by Christian Wilhelm
//

import SwiftUI

public struct LinkdingSettingsView: View {
    var secureToken: Binding<String> = Binding(
        get: {
            guard let value = try? SecureSettingsSupport.getSecureSettingString(key: LinkdingSettingKeys.settingsToken.rawValue) else {
                return ""
            }
            return value
        },
        set: {
            try? SecureSettingsSupport.setSecureSettingString(key: LinkdingSettingKeys.settingsToken.rawValue, value: $0)
        }
    )
    @AppStorage(LinkdingSettingKeys.settingsUrl.rawValue, store: AppStorageSupport.shared.sharedStore) var url: String = ""
    @AppStorage(LinkdingSettingKeys.createBookmarkDefaultArchived.rawValue, store: AppStorageSupport.shared.sharedStore) var defaultArchived: Bool = false
    @AppStorage(LinkdingSettingKeys.createBookmarkDefaultUnread.rawValue, store: AppStorageSupport.shared.sharedStore) var defaultUnread: Bool = false
    @AppStorage(LinkdingSettingKeys.createBookmarkDefaultShared.rawValue, store: AppStorageSupport.shared.sharedStore) var defaultShared: Bool = false

    @State var urlError: Bool = false
    @State var tokenError: Bool = false

    public init() {
    }
    
    public var body: some View {
        Section("Credentials") {
            VStack {
                TextField(text: self.$url) {
                    Text("URL")
                }
                .keyboardType(.URL)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onChange(of: self.url, perform: { newValue in
                    if (newValue == "") {
                        self.urlError = true
                    } else {
                        self.urlError = false
                    }
                })
                if (self.urlError) {
                    Text("URL is required.")
                        .foregroundColor(.red)
                }
            }
            VStack {
                SecureField(text: self.secureToken) {
                    Text("Token")
                }
                .textContentType(.password)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .onChange(of: self.secureToken.wrappedValue, perform: { newValue in
                    if (newValue == "") {
                        self.tokenError = true
                    } else {
                        self.tokenError = false
                    }
                })
                if (self.tokenError) {
                    Text("Token is required.")
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear() {
            self.urlError = self.url == ""
            self.tokenError = self.secureToken.wrappedValue == ""
        }
        Section("Default flags") {
            Toggle(isOn: self.$defaultUnread, label: { Text("Default flag for unread") })
            Toggle(isOn: self.$defaultShared, label: { Text("Default flag for shared") })
        }
    }
}


struct LinkdingSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            LinkdingSettingsView()
        }
    }
}

