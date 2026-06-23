//
//  CalendarMonthGrid.swift
//  PICHY
//

import SwiftUI

struct CalendarMonthGrid: View {
    let month: Date
    let today: Date
    let shiftLookup: (Date) -> [Shift]
    let onTapDay: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)

    var body: some View {
        VStack(spacing: 8) {
            // Weekday header
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(Array(BuddhistCalendar.weekdayHeaders.enumerated()), id: \.offset) { idx, name in
                    Text(name)
                        .font(AppFont.body(11, .semibold))
                        .foregroundColor(idx == 0 ? AppColors.peachActive : AppColors.textMuted)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar cells
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(buildCells().indices, id: \.self) { index in
                    let cell = buildCells()[index]
                    if let date = cell {
                        CalendarDayCell(
                            date: date,
                            isToday: Calendar.gregorian.isDate(date, inSameDayAs: today),
                            shifts: shiftLookup(date),
                            onTap: { onTapDay(date) }
                        )
                    } else {
                        Color.clear.frame(height: 45)
                    }
                }
            }
        }
    }

    /// Returns a 6×7 grid of optional dates aligned to Sunday-first weeks.
    private func buildCells() -> [Date?] {
        let cal = Calendar.gregorian
        let comps = cal.dateComponents([.year, .month], from: month)
        guard let firstOfMonth = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: firstOfMonth) else {
            return []
        }
        let leading = cal.component(.weekday, from: firstOfMonth) - 1
        var cells: [Date?] = Array(repeating: nil, count: leading)
        for day in range {
            cells.append(cal.date(byAdding: .day, value: day - 1, to: firstOfMonth))
        }
        while cells.count % 7 != 0 { cells.append(nil) }
        return cells
    }
}
