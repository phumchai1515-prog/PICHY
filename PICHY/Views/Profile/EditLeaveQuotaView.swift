//
//  EditLeaveQuotaView.swift
//  PICHY
//
//  Edit yearly leave quota (per Thai fiscal year). Set by the user.
//

import SwiftUI

struct EditLeaveQuotaView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var sick: Int
    @State private var personal: Int
    @State private var vacation: Int

    init(quota: LeaveQuota) {
        _sick = State(initialValue: quota.sick)
        _personal = State(initialValue: quota.personal)
        _vacation = State(initialValue: quota.vacation)
    }

    var body: some View {
        ZStack {
            AppColors.bgScreen.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    Text("ตั้งจำนวนวันลาที่ได้ต่อ 1 ปีงบประมาณ (1 ต.ค. – 30 ก.ย.)\nระบบจะนับวันที่ใช้ไปและแสดงวันคงเหลือให้")
                        .font(AppFont.body(13, .regular))
                        .foregroundColor(AppColors.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    VStack(spacing: 0) {
                        quotaField(.sick, value: $sick)
                        rowDivider
                        quotaField(.personal, value: $personal)
                        rowDivider
                        quotaField(.vacation, value: $vacation)
                    }
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white))
                    .cardShadow()
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }

            VStack {
                Spacer()
                GradientButton(title: "บันทึก") {
                    store.updateQuota(LeaveQuota(sick: sick, personal: personal, vacation: vacation))
                    dismiss()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .navigationTitle("โควต้าวันลา")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var rowDivider: some View {
        Divider().background(AppColors.divider).padding(.leading, 60)
    }

    private func quotaField(_ kind: LeaveType, value: Binding<Int>) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous).fill(kind.tintBG)
                Image(systemName: kind.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(kind.color)
            }
            .frame(width: 36, height: 36)

            Text(kind.label)
                .font(AppFont.body(13, .semibold))
                .foregroundColor(AppColors.textPrimary)
            Spacer()

            HStack(spacing: 6) {
                TextField("0", value: value, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(AppFont.display(16, .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 44)
                Text("วัน")
                    .font(AppFont.body(12, .regular))
                    .foregroundColor(AppColors.textMuted)
                Stepper("", value: value, in: 0...365).labelsHidden()
            }
        }
        .padding(14)
    }
}
