//
//  ShiftChip.swift
//  PICHY
//

import SwiftUI

/// Tinted pill — used in the legend ("เช้า 8") and inline.
struct ShiftLegendPill: View {
    let type: ShiftType
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(type.dot).frame(width: 8, height: 8)
            Text("\(type.label) \(count)")
                .font(AppFont.body(11, .semibold))
                .foregroundColor(type.textColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(type.tintBG)
        )
    }
}

/// Square letter/icon chip — used for transaction rows + add-shift grid.
struct ShiftSquareChip: View {
    let type: ShiftType
    var size: CGFloat = 40
    var radius: CGFloat = 13

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(type.tintBG)
            Text(type.shortChip)
                .font(AppFont.body(type.shortChip.count > 1 ? 11 : 14, .bold))
                .foregroundColor(type.textColor)
        }
        .frame(width: size, height: size)
    }
}
