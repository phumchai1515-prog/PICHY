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
