//
//  ProfileSettingsView.swift
//  PICHY
//

import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var auth: AuthManager

    @State private var shiftReminder = true
    @State private var nightlySummary = true
    @State private var biometricEnabled = false
    @State private var pendingCount = 0
    @State private var showTestAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHead

                section(title: "อัตราค่าเวร (ใช้คำนวณรายได้)") {
                    NavigationLink {
                        EditRatesView(rates: store.rates)
                    } label: {
                        PayRateRow(type: .morning, label: "เวรเช้า", amount: store.rates.morningShift, suffix: "")
                    }
                    .buttonStyle(.plain)
                    rowDivider
                    PayRateRow(type: .afternoon, label: "เวรบ่าย", amount: store.rates.afternoonShift, suffix: "")
                    rowDivider
                    PayRateRow(type: .night, label: "เวรดึก", amount: store.rates.nightShift, suffix: "")
                    rowDivider
                    PayRateRow(type: .ot, label: "OT ต่อชั่วโมง", amount: store.rates.otPerHour, suffix: "")
                }

                section(title: "การแจ้งเตือน") {
                    SettingsToggleRow(icon: "bell.fill", title: "เตือนก่อนเข้าเวร", isOn: $shiftReminder)
                    if shiftReminder {
                        rowDivider
                        NavigationLink {
                            ReminderLeadPicker()
                        } label: {
                            SettingsChevronRow(icon: "clock.fill", title: "เตือนล่วงหน้า", value: store.settings.reminderLead.label)
                        }
                        .buttonStyle(.plain)
                    }
                    rowDivider
                    SettingsToggleRow(icon: "moon.stars.fill", title: "สรุปเวรพรุ่งนี้ (ตอนค่ำ)", isOn: $nightlySummary)
                    rowDivider
                    SettingsChevronRow(icon: "calendar.badge.clock", title: "แจ้งเตือนที่ตั้งไว้", value: "\(pendingCount) รายการ")
                    rowDivider
                    Button {
                        NotificationManager.shared.scheduleTest()
                        showTestAlert = true
                    } label: {
                        SettingsChevronRow(icon: "bell.badge.fill", title: "ทดสอบแจ้งเตือน", tint: AppColors.peachPrimary)
                    }
                    .buttonStyle(.plain)
                }

                section(title: "วันลา") {
                    NavigationLink {
                        EditLeaveQuotaView(quota: store.quota)
                    } label: {
                        SettingsChevronRow(
                            icon: "calendar.badge.checkmark",
                            title: "โควต้าวันลา (ปีงบประมาณ)",
                            value: "ลา \(store.quota.sick)/\(store.quota.personal)/\(store.quota.vacation)"
                        )
                    }
                    .buttonStyle(.plain)
                }

                section(title: "ความปลอดภัย") {
                    NavigationLink {
                        ChangePINView()
                    } label: {
                        SettingsChevronRow(icon: "lock.fill", title: "เปลี่ยนรหัส PIN")
                    }
                    .buttonStyle(.plain)
                    if auth.biometricKind != .none {
                        rowDivider
                        SettingsToggleRow(
                            icon: auth.biometricKind.iconName,
                            title: "ปลดล็อกด้วย \(auth.biometricKind.label)",
                            isOn: $biometricEnabled
                        )
                    }
                }

                section(title: "ข้อมูล") {
                    SettingsChevronRow(icon: "square.and.arrow.up", title: "ส่งออกตารางเวร PDF")
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(AppColors.bgScreen)
        .navigationBarHidden(true)
        .onAppear { syncFromStore() }
        .task { pendingCount = await NotificationManager.shared.pendingShiftCount() }
        .alert("ตั้งการทดสอบแล้ว", isPresented: $showTestAlert) {
            Button("ตกลง", role: .cancel) {}
        } message: {
            Text("การแจ้งเตือนทดสอบจะเด้งในอีกประมาณ 8 วินาที — ลองล็อกหน้าจอหรือออกจากแอปเพื่อดู")
        }
        .onChange(of: shiftReminder) { _, new in
            store.updateSettings(store.settings.updating(shiftReminder: new))
        }
        .onChange(of: nightlySummary) { _, new in
            store.updateSettings(store.settings.updating(nightlySummary: new))
        }
        .onChange(of: biometricEnabled) { _, new in
            auth.setBiometricEnabled(new)
            biometricEnabled = auth.biometricEnabled   // reflect rejection if no hardware
        }
    }

    private func syncFromStore() {
        shiftReminder = store.settings.shiftReminder
        nightlySummary = store.settings.nightlySummary
        biometricEnabled = auth.biometricEnabled
    }

    private var rowDivider: some View {
        Divider().background(AppColors.divider).padding(.leading, 60)
    }

    private var profileHead: some View {
        NavigationLink {
            EditProfileView(profile: store.profile)
        } label: {
            VStack(spacing: 10) {
                AvatarView(profile: store.profile, size: 80)
                    .heroShadow()
                Text(store.profile.name)
                    .font(AppFont.display(19, .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text("\(store.profile.role) · \(store.profile.hospital)")
                    .font(AppFont.body(11, .regular))
                    .foregroundColor(AppColors.textMuted)
                Text("แตะเพื่อแก้ไข")
                    .font(AppFont.body(10, .semibold))
                    .foregroundColor(AppColors.peachPrimary)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFont.body(12, .semibold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) { content() }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
                .cardShadow()
        }
    }
}

/// Picker for how far ahead shift reminders fire.
struct ReminderLeadPicker: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(ReminderLead.allCases) { lead in
                    Button {
                        store.updateSettings(store.settings.updating(reminderLead: lead))
                        dismiss()
                    } label: {
                        HStack {
                            Text(lead.label)
                                .font(AppFont.body(14, .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            if store.settings.reminderLead == lead {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.peachPrimary)
                            }
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if lead != ReminderLead.allCases.last {
                        Divider().background(AppColors.divider).padding(.leading, 16)
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white))
            .cardShadow()
            .padding(20)
        }
        .background(AppColors.bgScreen)
        .navigationTitle("เตือนล่วงหน้า")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { ProfileSettingsView() }
        .environmentObject(AppStore())
        .environmentObject(AuthManager())
}
