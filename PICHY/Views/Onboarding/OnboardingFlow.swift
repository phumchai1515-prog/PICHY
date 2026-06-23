//
//  OnboardingFlow.swift
//  PICHY
//
//  First-launch setup: profile → pay rates → app PIN. On finish it writes the
//  profile/rates to the store, creates the PIN, and asks for notification
//  permission. The user must set up rates before the app calculates income.
//

import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var auth: AuthManager

    private enum Step: Int, CaseIterable {
        case welcome, profile, rates, pin
    }

    @State private var step: Step = .welcome

    // Profile draft
    @State private var name = ""
    @State private var role = "พยาบาลวิชาชีพ"
    @State private var hospital = ""
    @State private var avatarData: Data?

    // Rates draft (start from sensible defaults)
    @State private var dayShift = PayRates.default.dayShift
    @State private var nightShift = PayRates.default.nightShift
    @State private var otPerHour = PayRates.default.otPerHour

    // PIN draft
    @State private var firstPIN: String?
    @State private var enableBiometric = false

    private var draftProfile: UserProfile {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let initial = trimmed.first.map(String.init) ?? "P"
        return UserProfile(name: trimmed.isEmpty ? "ผู้ใช้ PICHY" : trimmed,
                           role: role,
                           hospital: hospital.trimmingCharacters(in: .whitespaces),
                           initial: initial,
                           avatarData: avatarData)
    }

    var body: some View {
        ZStack {
            AppColors.bgScreen.ignoresSafeArea()
            content
                .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .welcome: welcomeStep
        case .profile: profileStep
        case .rates:   ratesStep
        case .pin:     pinStep
        }
    }

    // MARK: - Welcome

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()
            MascotView(pose: .full, size: 200)
            VStack(spacing: 10) {
                Text("ยินดีต้อนรับสู่ PICHY")
                    .font(AppFont.display(26, .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text("จัดการตารางเวรและคำนวณรายได้ของคุณ\nเริ่มต้นด้วยการตั้งค่าโปรไฟล์และอัตราค่าเวร")
                    .font(AppFont.body(14, .regular))
                    .foregroundColor(AppColors.textMuted)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            GradientButton(title: "เริ่มต้นใช้งาน") { advance() }
                .padding(.bottom, 24)
        }
    }

    // MARK: - Profile

    private var profileStep: some View {
        VStack(spacing: 20) {
            header(title: "โปรไฟล์ของคุณ", subtitle: "ตั้งชื่อและรูปโปรไฟล์")

            AvatarPicker(profile: draftProfile, size: 104) { avatarData = $0 }
                .padding(.top, 4)

            VStack(spacing: 12) {
                LabeledTextField(title: "ชื่อ", text: $name, placeholder: "เช่น พยาบาลแนน")
                LabeledTextField(title: "ตำแหน่ง", text: $role, placeholder: "พยาบาลวิชาชีพ")
                LabeledTextField(title: "โรงพยาบาล", text: $hospital, placeholder: "เช่น รพ.ศิริราช")
            }

            Spacer()
            GradientButton(title: "ถัดไป") { advance() }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                .padding(.bottom, 24)
        }
        .padding(.top, 24)
    }

    // MARK: - Rates

    private var ratesStep: some View {
        VStack(spacing: 20) {
            header(title: "อัตราค่าเวร", subtitle: "ค่าเวรของแต่ละโรงพยาบาลไม่เท่ากัน\nกรอกค่าเวรของคุณเพื่อให้ระบบคำนวณรายได้")

            VStack(spacing: 0) {
                AmountField(type: .morning, label: "เวรเช้า/บ่าย", amount: $dayShift)
                Divider().background(AppColors.divider).padding(.leading, 60)
                AmountField(type: .night, label: "เวรดึก", amount: $nightShift)
                Divider().background(AppColors.divider).padding(.leading, 60)
                AmountField(type: .ot, label: "OT ต่อชั่วโมง", amount: $otPerHour)
            }
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white))
            .cardShadow()

            Spacer()
            GradientButton(title: "ถัดไป") { advance() }
                .padding(.bottom, 24)
        }
        .padding(.top, 24)
    }

    // MARK: - PIN

    private var pinStep: some View {
        VStack {
            Spacer(minLength: 12)
            PINPadView(
                title: firstPIN == nil ? "ตั้งรหัส PIN" : "ยืนยันรหัส PIN",
                subtitle: firstPIN == nil
                    ? "ตั้งรหัส \(auth.pinLength) หลักสำหรับเข้าแอป"
                    : "ใส่รหัสเดิมอีกครั้งเพื่อยืนยัน",
                length: auth.pinLength,
                onComplete: handlePIN
            )
            if auth.biometricKind != .none {
                Toggle(isOn: $enableBiometric) {
                    Text("ปลดล็อกด้วย \(auth.biometricKind.label)")
                        .font(AppFont.body(13, .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
                .tint(AppColors.peachPrimary)
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
            Spacer()
        }
    }

    private func handlePIN(_ pin: String) -> Bool {
        if let first = firstPIN {
            guard pin == first else { return false }
            finish(pin: pin)
            return true
        } else {
            firstPIN = pin
            return true   // accept first entry, advance to confirm
        }
    }

    // MARK: - Flow

    private func advance() {
        guard let next = Step(rawValue: step.rawValue + 1) else { return }
        withAnimation(.easeInOut) { step = next }
    }

    private func finish(pin: String) {
        store.completeOnboarding(
            profile: draftProfile,
            rates: PayRates(dayShift: dayShift, nightShift: nightShift, otPerHour: otPerHour)
        )
        auth.setBiometricEnabled(enableBiometric)
        auth.createPIN(pin)
        Task { _ = await NotificationManager.shared.requestAuthorization() }
    }

    // MARK: - Helpers

    private func header(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(AppFont.display(24, .bold))
                .foregroundColor(AppColors.textPrimary)
            Text(subtitle)
                .font(AppFont.body(13, .regular))
                .foregroundColor(AppColors.textMuted)
                .multilineTextAlignment(.center)
        }
    }
}

/// Simple labeled text field used across onboarding and profile editing.
struct LabeledTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFont.body(12, .semibold))
                .foregroundColor(AppColors.textSecondary)
            TextField(placeholder, text: $text)
                .font(AppFont.body(15, .regular))
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white)
                )
                .cardShadow()
        }
    }
}
