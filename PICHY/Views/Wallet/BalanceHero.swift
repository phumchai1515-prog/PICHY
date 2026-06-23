//
//  BalanceHero.swift
//  PICHY
//

import SwiftUI

struct BalanceHero: View {
    let balance: Int
    let income: Int
    let expense: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppColors.peachGradient)

            // Decorative translucent circles
            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 180, height: 180)
                .offset(x: -60, y: -60)
            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 140, height: 140)
                .offset(x: 220, y: 100)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("คงเหลือเดือนนี้")
                        .font(AppFont.body(12, .regular))
                        .foregroundColor(.white.opacity(0.9))
                    Text(CurrencyFormatter.baht(balance))
                        .font(AppFont.display(34, .bold))
                        .foregroundColor(.white)
                }

                HStack(spacing: 12) {
                    InnerTile(
                        label: "รายรับ",
                        amount: income,
                        systemIcon: "arrow.up"
                    )
                    InnerTile(
                        label: "รายจ่าย",
                        amount: expense,
                        systemIcon: "arrow.down"
                    )
                }
            }
            .padding(20)
        }
        .heroShadow()
    }
}

private struct InnerTile: View {
    let label: String
    let amount: Int
    let systemIcon: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(Color.white.opacity(0.25))
                Image(systemName: systemIcon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppFont.body(11, .regular))
                    .foregroundColor(.white.opacity(0.85))
                Text(CurrencyFormatter.baht(amount))
                    .font(AppFont.display(15, .bold))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.15))
        )
    }
}
