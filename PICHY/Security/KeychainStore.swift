//
//  KeychainStore.swift
//  PICHY
//
//  Minimal Keychain wrapper for the app passcode. The PIN is stored as a
//  salted SHA-256 hash — never in plaintext, never in UserDefaults.
//

import Foundation
import Security
import CryptoKit

enum KeychainStore {
    private static let service = "communityjvl.PICHY.passcode"
    private static let account = "app-pin"

    // MARK: - Public API

    static var hasPIN: Bool { readHash() != nil }

    /// Stores the PIN as a salted hash. Returns false if the write fails.
    @discardableResult
    static func setPIN(_ pin: String) -> Bool {
        write(hash(pin))
    }

    static func verify(_ pin: String) -> Bool {
        guard let stored = readHash() else { return false }
        // Constant-time-ish compare on equal-length hex strings.
        let candidate = hash(pin)
        guard candidate.count == stored.count else { return false }
        var diff: UInt8 = 0
        for (a, b) in zip(candidate.utf8, stored.utf8) { diff |= a ^ b }
        return diff == 0
    }

    // MARK: - Hashing

    private static func hash(_ pin: String) -> String {
        // Static app salt; combined with the Keychain's device protection this
        // is sufficient for a local-only passcode (not a server credential).
        let salted = "PICHY.v1.\(pin)"
        let digest = SHA256.hash(data: Data(salted.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Keychain I/O

    private static func write(_ value: String) -> Bool {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess { return true }
        if updateStatus == errSecItemNotFound {
            var insert = query
            insert.merge(attributes) { _, new in new }
            return SecItemAdd(insert as CFDictionary, nil) == errSecSuccess
        }
        return false
    }

    private static func readHash() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let value = String(data: data, encoding: .utf8) else { return nil }
        return value
    }
}
