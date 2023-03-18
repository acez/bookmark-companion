//
// SecureSettingsSupport.swift
// Created by Christian Wilhelm
//

import Foundation

public class SecureSettingsSupport {
    public static func setSecureSettingString(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw SecureSettingsError()
        }
        let keychainItemQuery = [
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessGroup: "group.bookmarkcompanion"
        ] as CFDictionary
        SecItemDelete(keychainItemQuery)
        SecItemAdd(keychainItemQuery, nil)
    }

    public static func getSecureSettingString(key: String) throws -> String {
        let keychainItemQuery = [
            kSecAttrAccount: key,
            kSecClass: kSecClassGenericPassword,
            kSecReturnAttributes: true,
            kSecReturnData: true,
            kSecMatchLimit: 1,
            kSecAttrAccessGroup: "group.bookmarkcompanion"
        ] as CFDictionary
        var result: AnyObject?
        SecItemCopyMatching(keychainItemQuery, &result)
        guard let data = result else {
            throw SecureSettingsError()
        }
        let resultData = data[kSecValueData] as! Data
        guard let strValue = String(data: resultData, encoding: .utf8) else {
            throw SecureSettingsError()
        }
        return strValue
    }

    public static func deleteSecureSetting(key: String) {
        let keychainItemQuery = [
            kSecAttrAccount: key,
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessGroup: "group.bookmarkcompanion"
        ] as CFDictionary
        SecItemDelete(keychainItemQuery)
    }
}
