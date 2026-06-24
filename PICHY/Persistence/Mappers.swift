//
//  Mappers.swift
//  PICHY
//
//  Pure conversions between SwiftData entities and immutable domain structs.
//

import Foundation

// MARK: - Shift

extension ShiftEntity {
    var asDomain: Shift {
        Shift(
            id: id,
            date: date,
            type: ShiftType(rawValue: typeRaw) ?? .custom,
            otHours: otHours,
            note: note,
            leaveType: leaveTypeRaw.flatMap { LeaveType(rawValue: $0) }
        )
    }

    static func make(from shift: Shift) -> ShiftEntity {
        ShiftEntity(
            id: shift.id,
            date: shift.date,
            typeRaw: shift.type.rawValue,
            otHours: shift.otHours,
            note: shift.note,
            leaveTypeRaw: shift.leaveType?.rawValue
        )
    }
}

// MARK: - Transaction

extension TransactionEntity {
    var asDomain: Transaction {
        Transaction(
            id: id,
            date: date,
            amount: amount,
            title: title,
            category: category,
            kind: TransactionKind(rawValue: kindRaw) ?? .expense,
            source: TransactionSource(rawValue: sourceRaw) ?? .manual,
            shiftType: shiftTypeRaw.flatMap { ShiftType(rawValue: $0) },
            note: note
        )
    }

    static func make(from t: Transaction) -> TransactionEntity {
        TransactionEntity(
            id: t.id,
            date: t.date,
            amount: t.amount,
            title: t.title,
            category: t.category,
            kindRaw: t.kind.rawValue,
            sourceRaw: t.source.rawValue,
            shiftTypeRaw: t.shiftType?.rawValue,
            note: t.note
        )
    }
}

// MARK: - Activity

extension ActivityEntity {
    var asDomain: Activity {
        Activity(
            id: id,
            date: date,
            time: time,
            title: title,
            category: ActivityCategory(rawValue: categoryRaw) ?? .personal,
            note: note
        )
    }

    static func make(from a: Activity) -> ActivityEntity {
        ActivityEntity(
            id: a.id,
            date: a.date,
            time: a.time,
            title: a.title,
            categoryRaw: a.category.rawValue,
            note: a.note
        )
    }
}

// MARK: - AppState

extension AppStateEntity {
    var rates: PayRates {
        PayRates(
            morningShift: dayShift,
            // 0 means the row predates the morning/afternoon split: fall back to morning.
            afternoonShift: afternoonShift == 0 ? dayShift : afternoonShift,
            nightShift: nightShift,
            otPerHour: otPerHour
        )
    }

    var profile: UserProfile {
        UserProfile(name: name, role: role, hospital: hospital, initial: initial, avatarData: avatarData)
    }

    var settings: AppSettings {
        AppSettings(
            shiftReminder: shiftReminder,
            iCloudBackup: iCloudBackup,
            reminderLead: ReminderLead(rawValue: reminderLeadMinutes) ?? .hour5,
            nightlySummary: nightlySummary
        )
    }

    var quota: LeaveQuota {
        LeaveQuota(sick: sickQuota, personal: personalQuota, vacation: vacationQuota)
    }

    func apply(quota: LeaveQuota) {
        sickQuota = quota.sick
        personalQuota = quota.personal
        vacationQuota = quota.vacation
    }

    func apply(rates: PayRates) {
        dayShift = rates.morningShift
        afternoonShift = rates.afternoonShift
        nightShift = rates.nightShift
        otPerHour = rates.otPerHour
    }

    func apply(profile: UserProfile) {
        name = profile.name
        role = profile.role
        hospital = profile.hospital
        initial = profile.initial
        avatarData = profile.avatarData
    }

    func apply(settings: AppSettings) {
        shiftReminder = settings.shiftReminder
        iCloudBackup = settings.iCloudBackup
        reminderLeadMinutes = settings.reminderLead.rawValue
        nightlySummary = settings.nightlySummary
    }

    static func makeDefault() -> AppStateEntity {
        // Neutral, empty profile until the user registers (onboarding overwrites
        // these). No sample name/hospital is persisted.
        AppStateEntity(
            dayShift: PayRates.default.morningShift,
            afternoonShift: PayRates.default.afternoonShift,
            nightShift: PayRates.default.nightShift,
            otPerHour: PayRates.default.otPerHour,
            name: "",
            role: "",
            hospital: "",
            initial: "",
            avatarData: nil,
            shiftReminder: AppSettings.default.shiftReminder,
            iCloudBackup: AppSettings.default.iCloudBackup,
            reminderLeadMinutes: AppSettings.default.reminderLead.rawValue,
            nightlySummary: AppSettings.default.nightlySummary,
            hasOnboarded: false
        )
    }
}
