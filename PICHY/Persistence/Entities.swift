//
//  Entities.swift
//  PICHY
//
//  SwiftData persistence models. These are the only mutable, reference-type
//  models in the app — the domain layer stays immutable (see Models/).
//  Map to/from the domain structs via Mappers.swift.
//

import Foundation
import SwiftData

@Model
final class ShiftEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var typeRaw: String
    var otHours: Int
    var note: String?
    var leaveTypeRaw: String?

    init(id: UUID, date: Date, typeRaw: String, otHours: Int, note: String?, leaveTypeRaw: String? = nil) {
        self.id = id
        self.date = date
        self.typeRaw = typeRaw
        self.otHours = otHours
        self.note = note
        self.leaveTypeRaw = leaveTypeRaw
    }
}

@Model
final class TransactionEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var amount: Int
    var title: String
    var category: String
    var kindRaw: String
    var sourceRaw: String
    var shiftTypeRaw: String?
    var note: String?

    init(id: UUID,
         date: Date,
         amount: Int,
         title: String,
         category: String,
         kindRaw: String,
         sourceRaw: String,
         shiftTypeRaw: String?,
         note: String?) {
        self.id = id
        self.date = date
        self.amount = amount
        self.title = title
        self.category = category
        self.kindRaw = kindRaw
        self.sourceRaw = sourceRaw
        self.shiftTypeRaw = shiftTypeRaw
        self.note = note
    }
}

@Model
final class ActivityEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var time: String
    var title: String
    var categoryRaw: String
    var note: String?

    init(id: UUID, date: Date, time: String, title: String, categoryRaw: String, note: String?) {
        self.id = id
        self.date = date
        self.time = time
        self.title = title
        self.categoryRaw = categoryRaw
        self.note = note
    }
}

/// Singleton row holding rates, profile, settings and first-launch state.
@Model
final class AppStateEntity {
    // Pay rates (dayShift retained as the morning rate for a safe lightweight
    // migration; afternoonShift defaults to 0 = "same as morning" for old rows).
    var dayShift: Int
    var afternoonShift: Int = 0
    var nightShift: Int
    var otPerHour: Int

    // Profile
    var name: String
    var role: String
    var hospital: String
    var initial: String
    @Attribute(.externalStorage) var avatarData: Data?

    // Settings
    var shiftReminder: Bool
    var iCloudBackup: Bool
    var reminderLeadMinutes: Int
    var nightlySummary: Bool

    // Leave quota (per fiscal year)
    var sickQuota: Int = 30
    var personalQuota: Int = 10
    var vacationQuota: Int = 10

    // First-launch / onboarding
    var hasOnboarded: Bool

    init(dayShift: Int,
         afternoonShift: Int = 0,
         nightShift: Int,
         otPerHour: Int,
         name: String,
         role: String,
         hospital: String,
         initial: String,
         avatarData: Data?,
         shiftReminder: Bool,
         iCloudBackup: Bool,
         reminderLeadMinutes: Int,
         nightlySummary: Bool,
         sickQuota: Int = 30,
         personalQuota: Int = 10,
         vacationQuota: Int = 10,
         hasOnboarded: Bool) {
        self.dayShift = dayShift
        self.afternoonShift = afternoonShift
        self.nightShift = nightShift
        self.otPerHour = otPerHour
        self.name = name
        self.role = role
        self.hospital = hospital
        self.initial = initial
        self.avatarData = avatarData
        self.shiftReminder = shiftReminder
        self.iCloudBackup = iCloudBackup
        self.reminderLeadMinutes = reminderLeadMinutes
        self.nightlySummary = nightlySummary
        self.sickQuota = sickQuota
        self.personalQuota = personalQuota
        self.vacationQuota = vacationQuota
        self.hasOnboarded = hasOnboarded
    }
}
