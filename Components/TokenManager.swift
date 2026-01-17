//
//  TokenManager.swift
//  money-manage
//
//  Created by Fawwaz Bayureksa on 17/01/26.
//

import Security
import Foundation

final class TokenManager {

    static let shared = TokenManager()
    private init() {}

    private let service = "com.moneymanage.app"
    private let account = "auth_token"

    // ✅ SET TOKEN
    func saveToken(_ token: String) {
        let data = Data(token.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        // hapus token lama jika ada
        SecItemDelete(query as CFDictionary)

        // simpan token baru
        SecItemAdd(query as CFDictionary, nil)
    }

    // ✅ GET TOKEN
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess,
              let data = dataTypeRef as? Data else {
            return nil
        }

        return String(decoding: data, as: UTF8.self)
    }

    // ✅ DELETE TOKEN (logout)
    func clearToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
