//
//  ShiftLegendRow.swift
//  PICHY
//

import SwiftUI

struct ShiftLegendRow: View {
    let counts: [ShiftType: Int]

    private static let order: [ShiftType] = [.morning, .afternoon, .night, .ot]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Self.order, id: \.self) { type in
                ShiftLegendPill(type: type, count: counts[type] ?? 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
