//
//  ShiftType.swift
//  PICHY
//

import SwiftUI

enum ShiftType: String, CaseIterable, Codable, Identifiable {
    case morning, afternoon, night, off, ot, custom
    var id: String { rawValue }

    var label: String {
        switch self {
        case .morning:   return "เช้า"
        case .afternoon: return "บ่าย"
        case .night:     return "ดึก"
        case .off:       return "วันหยุด"
        case .ot:        return "OT"
        case .custom:    return "อื่นๆ"
        }
    }

    var shortChip: String {
        switch self {
        case .morning:   return "ช"
        case .afternoon: return "บ"
        case .night:     return "ด"
        case .off:       return "พัก"
        case .ot:        return "OT"
        case .custom:    return "+"
        }
    }

    var timeRange: String {
        switch self {
        case .morning:   return "08:00–16:00"
        case .afternoon: return "16:00–24:00"
        case .night:     return "00:00–08:00"
        case .off:       return "ไม่มีเวร"
        case .ot:        return "ตามเวร"
        case .custom:    return "กำหนดเอง"
        }
    }

    /// Hour/minute the shift starts, for scheduling reminders.
    /// Returns `nil` for shift types with no fixed start time.
    var startTime: (hour: Int, minute: Int)? {
        switch self {
        case .morning:   return (8, 0)
        case .afternoon: return (16, 0)
        case .night:     return (0, 0)
        case .ot:        return (8, 0)
        case .off, .custom: return nil
        }
    }

    var dot: Color {
        switch self {
        case .morning:   return Color(hex: 0xEBA63F)
        case .afternoon: return Color(hex: 0x43B0A0)
        case .night:     return Color(hex: 0x7E6EE0)
        case .off:       return Color(hex: 0x329F61)
        case .ot:        return Color(hex: 0xEC6E95)
        case .custom:    return AppColors.peachPrimary
        }
    }

    var textColor: Color {
        switch self {
        case .morning:   return Color(hex: 0xA77B23)
        case .afternoon: return Color(hex: 0x1C8275)
        case .night:     return Color(hex: 0x6151C9)
        case .off:       return Color(hex: 0x329F61)
        case .ot:        return Color(hex: 0xCE5079)
        case .custom:    return AppColors.peachPrimary
        }
    }

    var tintBG: Color {
        switch self {
        case .morning:   return Color(hex: 0xFAEBD3)
        case .afternoon: return Color(hex: 0xDFF1ED)
        case .night:     return Color(hex: 0xEBE6FA)
        case .off:       return Color(hex: 0xE6F2E8)
        case .ot:        return Color(hex: 0xFAE3EB)
        case .custom:    return AppColors.surfacePeach
        }
    }
}
