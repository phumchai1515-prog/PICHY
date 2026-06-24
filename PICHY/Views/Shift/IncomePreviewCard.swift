//
//  IncomePreviewCard.swift
//  PICHY
//

import SwiftUI

struct IncomePreviewCard: View {
    let type: ShiftType
    let otHours: Int
    let rates: PayRates

    private var baseIncome: Int {
        switch type {
        case .morning, .ot: return rates.morningShift
        case .afternoon:    return rates.afternoonShift
        case .night:        return rates.nightShift
        case .off, .custom: return 0
        }
    }

    private var otIncome: Int { otHours * rates.otPerHour }
    private var total: Int { baseIncome + otIncome }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("รายได้เวรนี้ (คำนวณอัตโนมัติ)")
                .font(AppFont.body(12, .regular))
                .foregroundColor(Color(hex: 0xA77B23))

            HStack(alignment: .firstTextBaseline) {
                Text(breakdownLabel)
                    .font(AppFont.body(11, .regular))
                    .foregroundColor(Color(hex: 0xA77B23).opacity(0.8))
                Spacer()
                Text(CurrencyFormatter.baht(total))
                    .font(AppFont.display(22, .bold))
                    .foregroundColor(Color(hex: 0xA77B23))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: 0xFAEBD3))
        )
    }

    private var breakdownLabel: String {
        var parts: [String] = []
        if baseIncome > 0 {
            parts.append("เวร\(type.label) \(CurrencyFormatter.baht(baseIncome))")
        }
        if otIncome > 0 {
            parts.append("OT \(otHours)ชม. \(CurrencyFormatter.baht(otIncome))")
        }
        return parts.isEmpty ? "ไม่มีรายได้จากเวรนี้" : parts.joined(separator: " + ")
    }
}
