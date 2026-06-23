//
//  DonutBreakdownCard.swift
//  PICHY
//

import SwiftUI

struct DonutBreakdownCard: View {
    let counts: [ShiftType: Int]

    private static let order: [ShiftType] = [.morning, .afternoon, .night, .ot]

    private var total: Int {
        Self.order.reduce(0) { $0 + (counts[$1] ?? 0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("สัดส่วนเวรเดือนนี้")
                .font(AppFont.display(15, .semibold))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 20) {
                DonutShape(
                    segments: Self.order.map { ($0.dot, counts[$0] ?? 0) },
                    total: max(total, 1)
                )
                .frame(width: 108, height: 108)
                .overlay(
                    VStack(spacing: 0) {
                        Text("เวรรวม")
                            .font(AppFont.body(10, .regular))
                            .foregroundColor(AppColors.textMuted)
                        Text("\(total)")
                            .font(AppFont.display(20, .bold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                )

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Self.order, id: \.self) { type in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(type.dot)
                                .frame(width: 12, height: 12)
                            Text("\(type.label) \(counts[type] ?? 0)")
                                .font(AppFont.body(12, .medium))
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .cardShadow()
    }
}

private struct DonutShape: View {
    let segments: [(Color, Int)]
    let total: Int

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            ZStack {
                ForEach(segmentsWithAngles().indices, id: \.self) { i in
                    let s = segmentsWithAngles()[i]
                    Circle()
                        .trim(from: s.start, to: s.end)
                        .stroke(s.color, style: StrokeStyle(lineWidth: size * 0.18, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                        .frame(width: size * 0.85, height: size * 0.85)
                }
            }
            .frame(width: size, height: size)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func segmentsWithAngles() -> [(color: Color, start: CGFloat, end: CGFloat)] {
        var cursor: CGFloat = 0
        return segments.compactMap { (color, count) in
            guard count > 0 else { return nil }
            let span = CGFloat(count) / CGFloat(total)
            let start = cursor
            cursor += span
            return (color, start, cursor)
        }
    }
}
