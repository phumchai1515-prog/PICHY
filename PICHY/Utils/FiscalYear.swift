//
//  FiscalYear.swift
//  PICHY
//
//  Thai government fiscal year: 1 October – 30 September.
//  e.g. ปีงบประมาณ 2569 runs 1 Oct 2025 (พ.ศ. 2568) – 30 Sep 2026 (พ.ศ. 2569).
//

import Foundation

enum FiscalYear {
    private static let startMonth = 10  // October

    /// The half-open-ish [start, end] Gregorian range containing `date`.
    static func range(containing date: Date) -> (start: Date, end: Date) {
        let cal = Calendar.gregorian
        let comps = cal.dateComponents([.year, .month], from: date)
        let year = comps.year ?? 2025
        let month = comps.month ?? 1
        let startYear = month >= startMonth ? year : year - 1
        let start = cal.date(from: DateComponents(year: startYear, month: startMonth, day: 1))!
        let end = cal.date(from: DateComponents(year: startYear + 1, month: startMonth, day: 1))!
            .addingTimeInterval(-1)
        return (start, end)
    }

    /// Buddhist-era fiscal year number, e.g. 2569.
    static func buddhistYear(containing date: Date) -> Int {
        let cal = Calendar.gregorian
        let comps = cal.dateComponents([.year, .month], from: date)
        let year = comps.year ?? 2025
        let month = comps.month ?? 1
        let endGregYear = month >= startMonth ? year + 1 : year
        return endGregYear + 543
    }

    static func label(containing date: Date) -> String {
        "ปีงบประมาณ \(buddhistYear(containing: date))"
    }

    static func contains(_ date: Date, sameFiscalYearAs anchor: Date) -> Bool {
        let r = range(containing: anchor)
        return date >= r.start && date <= r.end
    }
}
