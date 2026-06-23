//
//  MonthSelectorCard.swift
//  PICHY
//

import SwiftUI

struct MonthSelectorCard: View {
    let month: Date
    let shiftCount: Int
    let monthlyIncome: Int
    let onPrev: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            chevronButton(systemName: "chevron.left", action: onPrev)

            VStack(spacing: 2) {
                Text(BuddhistCalendar.monthYearLong(month))
                    .font(AppFont.display(17, .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text("\(shiftCount) เวรเดือนนี้ · รายได้ \(CurrencyFormatter.baht(monthlyIncome))")
                    .font(AppFont.body(11, .regular))
                    .foregroundColor(AppColors.textMuted)
            }
            .frame(maxWidth: .infinity)

            chevronButton(systemName: "chevron.right", action: onNext)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .cardShadow()
    }

    private func chevronButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(AppColors.surfacePeach)
                Image(systemName: systemName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.peachPrimary)
            }
            .frame(width: 30, height: 30)
        }
        .buttonStyle(.pressableScale)
    }
}
