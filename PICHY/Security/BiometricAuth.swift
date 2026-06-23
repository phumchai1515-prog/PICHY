//
//  BiometricAuth.swift
//  PICHY
//
//  Thin wrapper over LocalAuthentication for Face ID / Touch ID unlock.
//

import Foundation
import LocalAuthentication

enum BiometricKind {
    case faceID, touchID, none

    var label: String {
        switch self {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        case .none:    return ""
        }
    }

    var iconName: String {
        switch self {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        case .none:    return "lock.fill"
        }
    }
}

enum BiometricAuth {
    static var available: BiometricKind {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        switch context.biometryType {
        case .faceID:  return .faceID
        case .touchID: return .touchID
        default:       return .none
        }
    }

    /// Prompts for Face/Touch ID. Returns true on success.
    static func authenticate(reason: String = "ปลดล็อกแอป PICHY") async -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "ใช้รหัส PIN"
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch {
            return false
        }
    }
}
