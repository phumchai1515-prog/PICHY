//
//  DateScroller.swift
//  PICHY
//

import SwiftUI

struct DateScroller: View {
    @Binding var selected: Date
    let anchor: Date
    var range: Int = 7

    private var days: [Date] {
        let cal = Calendar.gregorian
        return (-range...range).compactMap {
            cal.date(byAdding: .day, value: $0, to: anchor)
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(days, id: \.self) { day in
                        DateChip(
                            date: day,
                            isSelected: Calendar.gregorian.isDate(day, inSameDayAs: selected)
                        )
                        .id(day)
                        .onTapGesture { selected = day }
                    }
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                proxy.scrollTo(selected, anchor: .center)
            }
        }
    }
}

private struct DateChip: View {
    let date: Date
    let isSelected: Bool

    private var weekday: String {
        let w = Calendar.gregorian.component(.weekday, from: date)
        return ["อา.", "จ.", "อ.", "พ.", "พฤ.", "ศ.", "ส."][w - 1]
    }

    private var day: Int {
        Calendar.gregorian.component(.day, from: date)
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(weekday)
                .font(AppFont.body(10, .medium))
                .foregroundColor(isSelected ? .white.opacity(0.95) : AppColors.textMuted)
            Text("\(day)")
                .font(AppFont.display(16, .semibold))
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
        }
        .frame(width: 46, height: 60)
        .background(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppColors.peachGradient)
                        .heroShadow()
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white)
                        .cardShadow()
                }
            }
        )
    }
}
