//
//  ShiftDetailCard.swift
//  PICHY
//

import SwiftUI

struct ShiftDetailCard: View {
    @Binding var otEnabled: Bool
    @Binding var otHours: Int
    let type: ShiftType

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                CircleIconChip(systemName: "clock", size: 36, radius: 11)
                VStack(alignment: .leading, spacing: 2) {
                    Text("เวลาทำงาน")
                        .font(AppFont.body(11, .regular))
                        .foregroundColor(AppColors.textMuted)
                    Text(type.timeRange)
                        .font(AppFont.body(13, .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
                Spacer()
            }
            .padding(14)

            Divider().background(AppColors.divider).padding(.horizontal, 14)

            HStack(spacing: 12) {
                CircleIconChip(systemName: "sparkles", size: 36, radius: 11)
                VStack(alignment: .leading, spacing: 2) {
                    Text("เพิ่ม OT")
                        .font(AppFont.body(11, .regular))
                        .foregroundColor(AppColors.textMuted)
                    Text("\(otHours) ชม.")
                        .font(AppFont.body(13, .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }
                Spacer()
                Stepper("", value: $otHours, in: 1...12)
                    .labelsHidden()
                    .opacity(otEnabled ? 1 : 0)
                    .frame(width: 90)
                PeachToggle(isOn: $otEnabled)
            }
            .padding(14)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .cardShadow()
    }
}
