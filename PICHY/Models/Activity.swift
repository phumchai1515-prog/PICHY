//
//  Activity.swift
//  PICHY
//

import SwiftUI

enum ActivityCategory: String, Codable, CaseIterable {
    case morningShift, meeting, ot, personal

    var color: Color {
        switch self {
        case .morningShift: return Color(hex: 0xEBA63F)
        case .meeting:      return Color(hex: 0x43B0A0)
        case .ot:           return Color(hex: 0xEC6E95)
        case .personal:     return Color(hex: 0x7E6EE0)
        }
    }

    /// SF Symbol shown in the category chip and activity rows.
    var icon: String {
        switch self {
        case .morningShift: return "stethoscope"
        case .meeting:      return "person.2.fill"
        case .ot:           return "clock.arrow.circlepath"
        case .personal:     return "heart.fill"
        }
    }

    var tintBG: Color {
        switch self {
        case .morningShift: return Color(hex: 0xFAEBD3)
        case .meeting:      return Color(hex: 0xDFF1ED)
        case .ot:           return Color(hex: 0xFAE3EB)
        case .personal:     return Color(hex: 0xEBE6FA)
        }
    }
}

struct Activity: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let time: String
    let title: String
    let category: ActivityCategory
    let note: String?

    init(id: UUID = UUID(),
         date: Date,
         time: String,
         title: String,
         category: ActivityCategory,
         note: String? = nil) {
        self.id = id
        self.date = date
        self.time = time
        self.title = title
        self.category = category
        self.note = note
    }
}
