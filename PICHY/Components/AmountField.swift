//
//  AmountField.swift
//  PICHY
//
//  Labeled baht amount input with a shift-type chip, used wherever the user
//  edits pay rates.
//

import SwiftUI

struct AmountField: View {
    let type: ShiftType
    let label: String
    @Binding var amount: Int

    var body: some View {
        HStack(spacing: 12) {
            ShiftSquareChip(type: type, size: 36, radius: 11)
            Text(label)
                .font(AppFont.body(13, .semibold))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            HStack(spacing: 4) {
                Text("฿")
                    .font(AppFont.display(15, .semibold))
                    .foregroundColor(AppColors.textMuted)
                TextField("0", value: $amount, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(AppFont.display(16, .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 84)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppColors.surfacePeach)
            )
        }
        .padding(14)
    }
}
