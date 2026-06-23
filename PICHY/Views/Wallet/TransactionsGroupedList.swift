//
//  TransactionsGroupedList.swift
//  PICHY
//

import SwiftUI

struct TransactionsGroupedList: View {
    let groups: [(label: String, items: [Transaction])]

    var body: some View {
        VStack(spacing: 16) {
            ForEach(groups, id: \.label) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.label)
                        .font(AppFont.body(11, .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 4)

                    VStack(spacing: 0) {
                        ForEach(group.items.indices, id: \.self) { idx in
                            TransactionRow(transaction: group.items[idx])
                            if idx < group.items.count - 1 {
                                Divider()
                                    .background(AppColors.divider)
                                    .padding(.leading, 64)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white)
                    )
                    .cardShadow()
                }
            }
        }
    }
}

private struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            chip
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(AppFont.body(13, .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text(transaction.category)
                    .font(AppFont.body(11, .regular))
                    .foregroundColor(AppColors.textMuted)
            }
            Spacer()
            Text(CurrencyFormatter.signed(transaction.amount))
                .font(AppFont.display(15, .bold))
                .foregroundColor(transaction.kind == .income ? AppColors.incomeGreen : AppColors.expenseRose)
        }
        .padding(14)
    }

    @ViewBuilder
    private var chip: some View {
        if let st = transaction.shiftType {
            ShiftSquareChip(type: st)
        } else {
            CircleIconChip(
                systemName: iconForCategory(transaction.category),
                bg: AppColors.surfacePeach,
                fg: AppColors.peachPrimary
            )
        }
    }

    private func iconForCategory(_ label: String) -> String {
        switch label {
        case "อาหาร":    return "bag.fill"
        case "เดินทาง": return "car.fill"
        case "ช้อปปิ้ง": return "cart.fill"
        case "บิล":      return "doc.text.fill"
        default:        return "creditcard.fill"
        }
    }
}
