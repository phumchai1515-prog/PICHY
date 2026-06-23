//
//  BarChartCard.swift
//  PICHY
//

import SwiftUI

struct BarChartCard: View {
    let series: [(Date, Int)]

    private let maxBarHeight: CGFloat = 104

    private var maxValue: Int {
        max(series.map { $0.1 }.max() ?? 1, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("รายได้รายเดือน")
                    .font(AppFont.display(15, .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("6 เดือนล่าสุด")
                    .font(AppFont.body(11, .regular))
                    .foregroundColor(AppColors.textMuted)
            }

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(series.indices, id: \.self) { idx in
                    let value = series[idx].1
                    let height = CGFloat(value) / CGFloat(maxValue) * maxBarHeight
                    BarItem(
                        month: series[idx].0,
                        height: max(height, 12),
                        isCurrent: idx == series.count - 1,
                        index: idx
                    )
                }
            }
            .frame(height: maxBarHeight + 36)
            .padding(.top, 14)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .cardShadow()
    }
}

private struct BarItem: View {
    let month: Date
    let height: CGFloat
    let isCurrent: Bool
    let index: Int

    private var label: String {
        let m = Calendar.gregorian.component(.month, from: month)
        let labels = ["ม.ค.","ก.พ.","มี.ค.","เม.ย.","พ.ค.","มิ.ย.","ก.ค.","ส.ค.","ก.ย.","ต.ค.","พ.ย.","ธ.ค."]
        return labels[m - 1]
    }

    var body: some View {
        VStack(spacing: 6) {
            Spacer(minLength: 0)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(barFill)
                .frame(height: height)
            Text(label)
                .font(AppFont.body(10, .medium))
                .foregroundColor(isCurrent ? AppColors.peachActive : AppColors.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var barFill: AnyShapeStyle {
        if isCurrent {
            return AnyShapeStyle(AppColors.peachGradient)
        }
        // Alternating tints per design
        return AnyShapeStyle(index.isMultiple(of: 2)
                             ? Color(hex: 0xF8E2D2)
                             : Color(hex: 0xF4CDB4))
    }
}
