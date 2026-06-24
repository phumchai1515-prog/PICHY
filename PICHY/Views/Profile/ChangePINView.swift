//
//  ChangePINView.swift
//  PICHY
//
//  Verify current PIN, then set a new one.
//

import SwiftUI

struct ChangePINView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) private var dismiss

    private enum Phase { case verify, new, confirm }
    @State private var phase: Phase = .verify
    @State private var currentPIN: String?
    @State private var newPIN: String?

    var body: some View {
        ZStack {
            AppColors.bgScreen.ignoresSafeArea()
            VStack {
                Spacer(minLength: 12)
                PINPadView(
                    title: title,
                    subtitle: subtitle,
                    length: auth.pinLength,
                    onComplete: handle
                )
                Spacer()
            }
        }
        .navigationTitle("เปลี่ยนรหัส PIN")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var title: String {
        switch phase {
        case .verify:  return "รหัสเดิม"
        case .new:     return "รหัสใหม่"
        case .confirm: return "ยืนยันรหัสใหม่"
        }
    }

    private var subtitle: String {
        switch phase {
        case .verify:  return "ใส่รหัส PIN ปัจจุบัน"
        case .new:     return "ตั้งรหัส \(auth.pinLength) หลักใหม่"
        case .confirm: return "ใส่รหัสใหม่อีกครั้ง"
        }
    }

    private func handle(_ pin: String) -> Bool {
        switch phase {
        case .verify:
            guard auth.unlock(with: pin) else { return false }
            currentPIN = pin
            phase = .new
            return true
        case .new:
            newPIN = pin
            phase = .confirm
            return true
        case .confirm:
            guard let current = currentPIN, let target = newPIN, pin == target,
                  auth.changePIN(current: current, new: pin) else { return false }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss()
            return true
        }
    }
}
