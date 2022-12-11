//
// LinkdingSettingsValidator.swift
// Created by Christian Wilhelm
//

import Foundation

public class LinkdingSettingsValidator {
    public init() {
    }

    public func validateSettings() -> Bool {
        guard let url = AppStorageSupport.shared.sharedStore.string(forKey: LinkdingSettingKeys.settingsUrl.rawValue) else {
            return false
        }
        guard let secureToken = try? SecureSettingsSupport.getSecureSettingString(key: LinkdingSettingKeys.settingsToken.rawValue) else {
            return false
        }

        return url != "" && secureToken != ""
    }
}
