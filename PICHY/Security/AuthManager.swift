//
//  AuthManager.swift
//  PICHY
//
//  Owns the app-lock state machine: needs a PIN set, locked, or unlocked.
//  Biometrics are an optional convenience layered on top of the PIN.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class AuthManager: ObservableObject {

    enum LockState: Equatable {
        case needsSetup   // no PIN exists yet (handled by onboarding)
        case locked       // PIN exists, awaiting unlock
        case unlocked
    }

    @Published private(set) var state: LockState
    @Published private(set) var biometricEnabled: Bool

    let pinLength = 6
    private let biometricFlagKey = "pichy.biometricEnabled"

    init() {
        state = KeychainStore.hasPIN ? .locked : .needsSetup
        biometricEnabled = UserDefaults.standard.bool(forKey: biometricFlagKey)
    }

    var hasPIN: Bool { KeychainStore.hasPIN }
    var biometricKind: BiometricKind { BiometricAuth.available }

    // MARK: - Setup / change

    /// Creates the initial PIN (used during onboarding).
    @discardableResult
    func createPIN(_ pin: String) -> Bool {
        guard pin.count == pinLength, KeychainStore.setPIN(pin) else { return false }
        state = .unlocked
        return true
    }

    @discardableResult
    func changePIN(current: String, new: String) -> Bool {
        guard KeychainStore.verify(current), new.count == pinLength else { return false }
        return KeychainStore.setPIN(new)
    }

    // MARK: - Unlock

    @discardableResult
    func unlock(with pin: String) -> Bool {
        guard KeychainStore.verify(pin) else { return false }
        state = .unlocked
        return true
    }

    func unlockWithBiometrics() async -> Bool {
        guard biometricEnabled, biometricKind != .none else { return false }
        let ok = await BiometricAuth.authenticate()
        if ok { state = .unlocked }
        return ok
    }

    func lock() {
        if KeychainStore.hasPIN { state = .locked }
    }

    // MARK: - Settings

    func setBiometricEnabled(_ enabled: Bool) {
        biometricEnabled = enabled && biometricKind != .none
        UserDefaults.standard.set(biometricEnabled, forKey: biometricFlagKey)
    }

    /// Removes the PIN entirely (e.g. user disables app lock).
    func removePIN() {
        KeychainStore.deletePIN()
        setBiometricEnabled(false)
        state = .needsSetup
    }
}
