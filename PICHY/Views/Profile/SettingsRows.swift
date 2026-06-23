//
//  SettingsRows.swift
//  PICHY
//

import SwiftUI

struct PayRateRow: View {
    let type: ShiftType
    let label: String
    let amount: Int
    let suffix: String

    var body: some View {
        HStack(spacing: 12) {
            ShiftSquareChip(type: type, size: 36, radius: 11)
            Text(label)
                .font(AppFont.body(13, .semibold))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Text(CurrencyFormatter.baht(amount) + suffix)
                .font(AppFont.display(15, .bold))
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(14)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            CircleIconChip(systemName: icon, size: 36, radius: 11)
            Text(title)
                .font(AppFont.body(13, .semibold))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            PeachToggle(isOn: $isOn)
        }
        .padding(14)
    }
}

struct SettingsChevronRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var tint: Color? = nil

    var body: some View {
        HStack(spacing: 12) {
            CircleIconChip(systemName: icon, size: 36, radius: 11)
            Text(title)
                .font(AppFont.body(13, .semibold))
                .foregroundColor(tint ?? AppColors.textPrimary)
            Spacer()
            if let value {
                Text(value)
                    .font(AppFont.body(13, .regular))
                    .foregroundColor(AppColors.textMuted)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.textMuted)
        }
        .padding(14)
        .contentShape(Rectangle())
    }
}

