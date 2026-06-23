//
//  LeaveType.swift
//  PICHY
//
//  Kinds of non-working days. A Shift of type `.off` carries one of these to
//  say *why* the day is off. Sick/personal/vacation count against a yearly quota.
//

import SwiftUI

enum LeaveType: String, Codable, CaseIterable, Identifiable {
    case dayOff         // วันหยุด (พัก)
    case publicHoliday  // วันหยุดนักขัตฤกษ์
    case sick           // ลาป่วย
    case personal       // ลากิจ
    case vacation       // ลาพักร้อน

    var id: String { rawValue }

    var label: String {
        switch self {
        case .dayOff:        return "วันหยุด"
        case .publicHoliday: return "วันหยุดนักขัตฤกษ์"
        case .sick:          return "ลาป่วย"
        case .personal:      return "ลากิจ"
        case .vacation:      return "ลาพักร้อน"
        }
    }

    var shortLabel: String {
        switch self {
        case .dayOff:        return "พัก"
        case .publicHoliday: return "นักขัตฤกษ์"
        case .sick:          return "ป่วย"
        case .personal:      return "กิจ"
        case .vacation:      return "พักร้อน"
        }
    }

    var icon: String {
        switch self {
        case .dayOff:        return "moon.stars.fill"
        case .publicHoliday: return "flag.fill"
        case .sick:          return "cross.case.fill"
        case .personal:      return "person.fill"
        case .vacation:      return "beach.umbrella.fill"
        }
    }

    var color: Color {
        switch self {
        case .dayOff:        return Color(hex: 0x329F61)
        case .publicHoliday: return Color(hex: 0xE5894B)
        case .sick:          return Color(hex: 0xCE5079)
        case .personal:      return Color(hex: 0x7E6EE0)
        case .vacation:      return Color(hex: 0x43B0A0)
        }
    }

    var tintBG: Color {
        switch self {
        case .dayOff:        return Color(hex: 0xE6F2E8)
        case .publicHoliday: return Color(hex: 0xFBEAD9)
        case .sick:          return Color(hex: 0xFAE3EB)
        case .personal:      return Color(hex: 0xEBE6FA)
        case .vacation:      return Color(hex: 0xDFF1ED)
        }
    }

    /// Whether this leave draws down a yearly quota.
    var hasQuota: Bool {
        switch self {
        case .sick, .personal, .vacation: return true
        case .dayOff, .publicHoliday:     return false
        }
    }

    /// Leave kinds that count against quota, in display order.
    static var quotaKinds: [LeaveType] { [.sick, .personal, .vacation] }
}
