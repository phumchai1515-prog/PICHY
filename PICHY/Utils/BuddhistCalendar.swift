//
//  BuddhistCalendar.swift
//  PICHY
//

import Foundation

enum BuddhistCalendar {
    private static let thaiMonthsFull = [
        "มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภาคม", "มิถุนายน",
        "กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤศจิกายน", "ธันวาคม"
    ]

    private static let thaiMonthsShort = [
        "ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.",
        "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค."
    ]

    private static let thaiWeekdaysShort = ["อา", "จ", "อ", "พ", "พฤ", "ศ", "ส"]
    private static let thaiWeekdaysFull  = ["อาทิตย์", "จันทร์", "อังคาร", "พุธ", "พฤหัสบดี", "ศุกร์", "เสาร์"]

    static let weekdayHeaders = thaiWeekdaysShort

    static func monthYearLong(_ date: Date) -> String {
        let c = Calendar.gregorian.dateComponents([.month, .year], from: date)
        guard let m = c.month, let y = c.year else { return "" }
        return "\(thaiMonthsFull[m - 1]) \(y + 543)"
    }

    static func dayOfWeekLong(_ date: Date) -> String {
        let c = Calendar.gregorian.component(.weekday, from: date)
        return thaiWeekdaysFull[c - 1]
    }

    static func dayMonthShort(_ date: Date) -> String {
        let c = Calendar.gregorian.dateComponents([.day, .month], from: date)
        guard let d = c.day, let m = c.month else { return "" }
        return "\(d) \(thaiMonthsShort[m - 1])"
    }

    static func fullDate(_ date: Date) -> String {
        let c = Calendar.gregorian.dateComponents([.day, .month, .year], from: date)
        guard let d = c.day, let m = c.month, let y = c.year else { return "" }
        return "\(dayOfWeekLong(date)) \(d) \(thaiMonthsFull[m - 1]) \(y + 543)"
    }

    static func dateLabelMedium(_ date: Date) -> String {
        let c = Calendar.gregorian.dateComponents([.weekday, .day, .month], from: date)
        guard let w = c.weekday, let d = c.day, let m = c.month else { return "" }
        return "\(thaiWeekdaysFull[w - 1]) \(d) \(thaiMonthsShort[m - 1])"
    }

    static func greeting(for date: Date) -> String {
        let hour = Calendar.gregorian.component(.hour, from: date)
        switch hour {
        case 5..<12:  return "สวัสดีตอนเช้า ☀"
        case 12..<17: return "สวัสดีตอนบ่าย"
        case 17..<21: return "สวัสดีตอนเย็น"
        default:      return "สวัสดีตอนค่ำ"
        }
    }
}

extension Calendar {
    /// Cached gregorian calendar (th_TH, Sunday-first). Built once instead of on
    /// every access, since it is used heavily inside date-filtering loops.
    static let gregorian: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: "th_TH")
        cal.firstWeekday = 1 // Sunday
        return cal
    }()

    func startOfMonth(for date: Date) -> Date {
        self.date(from: dateComponents([.year, .month], from: date)) ?? date
    }
}
