//
//  LockScreenView.swift
//  PICHY
//
//  Shown whenever the app is locked. Unlock with PIN or, if enabled, biometrics.
//

import SwiftUI

struct LockScreenView: View {
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        ZStack {
            AppColors.bgScreen.ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                MascotBadge(size: 96)

                PINPadView(
                    title: "ปลดล็อก PICHY",
                    subtitle: "ใส่รหัส PIN \(auth.pinLength) หลัก",
                    length: auth.pinLength,
                    biometric: auth.biometricEnabled ? auth.biometricKind : .none,
                    onBiometric: { Task { await auth.unlockWithBiometrics() } },
                    onComplete: { auth.unlock(with: $0) }
                )

                Spacer()
            }
        }
        .task {
            // Offer biometrics immediately when enabled.
            if auth.biometricEnabled {
                await auth.unlockWithBiometrics()
            }
        }
    }
}
