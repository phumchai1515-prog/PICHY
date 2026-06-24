//
//  PayRates.swift
//  PICHY
//

import Foundation

struct PayRates: Codable, Equatable {
    let morningShift: Int    // ค่าเวรเช้า
    let afternoonShift: Int  // ค่าเวรบ่าย
    let nightShift: Int      // ค่าเวรดึก
    let otPerHour: Int       // ค่า OT ต่อชั่วโมง

    static let `default` = PayRates(morningShift: 1200, afternoonShift: 1200, nightShift: 1500, otPerHour: 250)

    func updating(morningShift: Int? = nil,
                  afternoonShift: Int? = nil,
                  nightShift: Int? = nil,
                  otPerHour: Int? = nil) -> PayRates {
        PayRates(
            morningShift: morningShift ?? self.morningShift,
            afternoonShift: afternoonShift ?? self.afternoonShift,
            nightShift: nightShift ?? self.nightShift,
            otPerHour: otPerHour ?? self.otPerHour
        )
    }
}

struct UserProfile: Codable, Equatable {
    let name: String
    let role: String
    let hospital: String
    let initial: String
    let avatarData: Data?   // optional profile photo (JPEG/PNG bytes)

    static let `default` = UserProfile(
        name: "พยาบาลแนน",
        role: "พยาบาลวิชาชีพ",
        hospital: "รพ.ศิริราช",
        initial: "น",
        avatarData: nil
    )

    init(name: String,
         role: String,
         hospital: String,
         initial: String,
         avatarData: Data? = nil) {
        self.name = name
        self.role = role
        self.hospital = hospital
        self.initial = initial
        self.avatarData = avatarData
    }

    func updating(name: String? = nil,
                  role: String? = nil,
                  hospital: String? = nil,
                  initial: String? = nil,
                  avatarData: Data?? = nil) -> UserProfile {
        UserProfile(
            name: name ?? self.name,
            role: role ?? self.role,
            hospital: hospital ?? self.hospital,
            initial: initial ?? self.initial,
            avatarData: avatarData ?? self.avatarData
        )
    }
}

/// How long before a shift starts the reminder fires.
enum ReminderLead: Int, Codable, CaseIterable, Identifiable {
    case min30 = 30
    case hour1 = 60
    case hour2 = 120
    case hour3 = 180
    case hour5 = 300
    case hour8 = 480
    case hour12 = 720

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .min30: return "30 นาที"
        case .hour1: return "1 ชั่วโมง"
        case .hour2: return "2 ชั่วโมง"
        case .hour3: return "3 ชั่วโมง"
        case .hour5: return "5 ชั่วโมง"
        case .hour8: return "8 ชั่วโมง"
        case .hour12: return "12 ชั่วโมง"
        }
    }
}

struct AppSettings: Codable, Equatable {
    let shiftReminder: Bool
    let iCloudBackup: Bool
    let reminderLead: ReminderLead
    let nightlySummary: Bool   // เตือนตอนเที่ยงคืนสรุปเวรพรุ่งนี้

    static let `default` = AppSettings(
        shiftReminder: true,
        iCloudBackup: false,
        reminderLead: .hour5,
        nightlySummary: true
    )

    init(shiftReminder: Bool,
         iCloudBackup: Bool,
         reminderLead: ReminderLead = .hour5,
         nightlySummary: Bool = true) {
        self.shiftReminder = shiftReminder
        self.iCloudBackup = iCloudBackup
        self.reminderLead = reminderLead
        self.nightlySummary = nightlySummary
    }

    func updating(shiftReminder: Bool? = nil,
                  iCloudBackup: Bool? = nil,
                  reminderLead: ReminderLead? = nil,
                  nightlySummary: Bool? = nil) -> AppSettings {
        AppSettings(
            shiftReminder: shiftReminder ?? self.shiftReminder,
            iCloudBackup: iCloudBackup ?? self.iCloudBackup,
            reminderLead: reminderLead ?? self.reminderLead,
            nightlySummary: nightlySummary ?? self.nightlySummary
        )
    }
}
