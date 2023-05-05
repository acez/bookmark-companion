//
//  AccessTokenMigrationToAppGroup.swift
//  Created by Christian Wilhelm
//

import Foundation

public class AccessTokenMigrationToAppGroup {
    public func  migrate() {
        if self.needsUpdate() {
            self.updateAccessGroup()
        }
    }
    
    private func updateAccessGroup() {
        guard let token = self.getTokenFromKeychain() else {
            return
        }
        self.deleteToken()
        try? SecureSettingsSupport.setSecureSettingString(
            key: LinkdingSettingKeys.settingsToken.rawValue,
            value: token
        )
    }
    
    private func needsUpdate() -> Bool {
        let keychainItemQuery = [
            kSecAttrAccount: LinkdingSettingKeys.settingsToken.rawValue,
            kSecClass: kSecClassGenericPassword,
            kSecReturnAttributes: true,
            kSecReturnData: true,
            kSecMatchLimit: 1
        ] as CFDictionary
        var result: AnyObject?
        SecItemCopyMatching(keychainItemQuery, &result)
        guard let data = result else {
            return false
        }
        guard let resultData = data[kSecAttrAccessGroup] else {
            return false
        }
        guard let accessGroup = resultData else {
            return false
        }
        return accessGroup as! String != "group.bookmarkcompanion"
    }
    
    private func getTokenFromKeychain() -> String? {
        let keychainItemQuery = [
            kSecAttrAccount: LinkdingSettingKeys.settingsToken.rawValue,
            kSecClass: kSecClassGenericPassword,
            kSecReturnAttributes: true,
            kSecReturnData: true,
            kSecMatchLimit: 1
        ] as CFDictionary
        var result: AnyObject?
        SecItemCopyMatching(keychainItemQuery, &result)
        guard let data = result else {
            return nil
        }
        let resultData = data[kSecValueData] as! Data
        guard let strValue = String(data: resultData, encoding: .utf8) else {
            return nil
        }
        return strValue
    }
    
    private func deleteToken() {
        let keychainItemQuery = [
            kSecAttrAccount: LinkdingSettingKeys.settingsToken.rawValue,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        SecItemDelete(keychainItemQuery)
    }
}
