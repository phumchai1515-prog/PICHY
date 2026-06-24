//
//  AppStore.swift
//  PICHY
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var shifts: [Shift] = []
    @Published private(set) var activities: [Activity] = []
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var rates: PayRates = .default
    @Published private(set) var profile: UserProfile = .default
    @Published private(set) var settings: AppSettings = .default
    @Published private(set) var quota: LeaveQuota = .default
    @Published private(set) var hasOnboarded: Bool = false

    /// "Today" anchor — start of the real current day.
    let today: Date

    private let persistence: PersistenceController
    private let notifications: NotificationManager

    init(persistence: PersistenceController = .shared,
         notifications: NotificationManager = .shared,
         now: Date = Date()) {
        self.persistence = persistence
        self.notifications = notifications
        self.today = Calendar.gregorian.startOfDay(for: now)

        apply(persistence.loadSnapshot())

        // App starts completely empty. The user registers (onboarding) and then
        // enters their own shifts and transactions — no sample/seed data.
        rescheduleNotifications()

        // Safety net for users who reach the app without the onboarding prompt
        // having granted permission (e.g. installed before it existed).
        let notifications = self.notifications
        Task { await notifications.requestAuthorizationIfNeeded() }
    }

    // MARK: - Snapshot / persistence

    private func apply(_ snapshot: DataSnapshot) {
        shifts = snapshot.shifts
        transactions = snapshot.transactions
        activities = snapshot.activities
        rates = snapshot.rates
        profile = snapshot.profile
        settings = snapshot.settings
        quota = snapshot.quota
        hasOnboarded = snapshot.hasOnboarded
    }

    private var snapshot: DataSnapshot {
        DataSnapshot(
            shifts: shifts,
            transactions: transactions,
            activities: activities,
            rates: rates,
            profile: profile,
            settings: settings,
            quota: quota,
            hasOnboarded: hasOnboarded
        )
    }

    private func persist() {
        persistence.persist(snapshot)
    }

    private func rescheduleNotifications() {
        // Use the real current time (not the day anchor) so reminders for later
        // today are evaluated precisely and past ones aren't scheduled.
        notifications.reschedule(shifts: shifts, settings: settings, from: Date())
    }

    // MARK: - Profile / onboarding

    func updateProfile(_ next: UserProfile) {
        profile = next
        persist()
    }

    func completeOnboarding(profile: UserProfile, rates: PayRates) {
        self.profile = profile
        self.rates = rates
        self.hasOnboarded = true
        rebuildShiftIncomes()   // persists
        rescheduleNotifications()
    }

    // MARK: - Shifts

    /// All shifts on a given day (a day may have several), ordered by start time.
    func shifts(on date: Date) -> [Shift] {
        shifts
            .filter { Calendar.gregorian.isDate($0.date, inSameDayAs: date) }
            .sorted { startKey($0) < startKey($1) }
    }

    /// Adds a new shift or updates an existing one (matched by id).
    /// Multiple shifts per day are allowed; the day's income is their sum.
    func upsertShift(_ shift: Shift) {
        var next = shifts.filter { $0.id != shift.id }
        next.append(shift)
        shifts = next.sorted { $0.date < $1.date }
        rebuildShiftIncomes()       // persists
        rescheduleNotifications()
    }

    func deleteShift(_ id: UUID) {
        shifts = shifts.filter { $0.id != id }
        rebuildShiftIncomes()       // persists
        rescheduleNotifications()
    }

    /// Marks every day in [start, end] as a leave/off day of the given kind in
    /// one action. Existing entries on those days are replaced.
    func setLeaveRange(from start: Date, to end: Date, leaveType: LeaveType) {
        let cal = Calendar.gregorian
        let lower = cal.startOfDay(for: min(start, end))
        let upper = cal.startOfDay(for: max(start, end))

        var rangeDays: [Date] = []
        var day = lower
        while day <= upper {
            rangeDays.append(day)
            guard let nextDay = cal.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay
        }

        // Drop any existing shifts on those days, then add one off shift each.
        var next = shifts.filter { sh in
            !rangeDays.contains { cal.isDate($0, inSameDayAs: sh.date) }
        }
        for d in rangeDays {
            next.append(Shift(date: d, type: .off, leaveType: leaveType))
        }
        shifts = next.sorted { $0.date < $1.date }
        rebuildShiftIncomes()       // persists
        rescheduleNotifications()
    }

    /// Sort weight within a day: earlier start time first; off/custom last.
    private func startKey(_ s: Shift) -> Int {
        s.type.startTime.map { $0.hour * 60 + $0.minute } ?? 9999
    }

    // MARK: - Activities (add/remove single)

    func addActivity(_ a: Activity) {
        activities = (activities + [a]).sorted { $0.time < $1.time }
        persist()
    }

    func deleteActivity(_ id: UUID) {
        activities = activities.filter { $0.id != id }
        persist()
    }

    // MARK: - Rates / Settings

    func updateRates(_ next: PayRates) {
        rates = next
        rebuildShiftIncomes()       // persists
        rescheduleNotifications()
    }

    func updateSettings(_ next: AppSettings) {
        settings = next
        persist()
        rescheduleNotifications()
    }

    func updateQuota(_ next: LeaveQuota) {
        quota = next
        persist()
    }

    // MARK: - Leave / day-off selectors

    /// All off/leave shifts in the same month as `date`, ordered by day.
    func leaveDaysInMonth(of date: Date) -> [Shift] {
        shiftsInMonth(of: date)
            .filter { $0.type == .off }
            .sorted { $0.date < $1.date }
    }

    /// Count of a given leave kind used within the fiscal year containing `date`.
    func leaveUsed(_ type: LeaveType, inFiscalYearOf date: Date) -> Int {
        shifts.filter {
            $0.type == .off
                && $0.resolvedLeave == type
                && FiscalYear.contains($0.date, sameFiscalYearAs: date)
        }.count
    }

    func leaveRemaining(_ type: LeaveType, inFiscalYearOf date: Date) -> Int {
        max(0, quota.days(for: type) - leaveUsed(type, inFiscalYearOf: date))
    }

    // MARK: - Transactions

    func addTransaction(_ t: Transaction) {
        transactions = (transactions + [t]).sorted { $0.date > $1.date }
        persist()
    }

    // MARK: - Activities

    func replaceActivities(_ next: [Activity]) {
        activities = next.sorted { $0.time < $1.time }
        persist()
    }

    func addActivities(_ extra: [Activity]) {
        activities = (activities + extra).sorted { $0.time < $1.time }
        persist()
    }

    /// Re-derive all shift-income transactions from the current shifts/rates.
    /// Keeps manual income/expense rows intact.
    private func rebuildShiftIncomes() {
        let manualRows = transactions.filter { $0.source == .manual }
        let derived = shifts.compactMap { shift -> Transaction? in
            let amount = shift.income(using: rates)
            guard amount > 0 else { return nil }
            return Transaction(
                date: shift.date,
                amount: amount,
                title: "เวร\(shift.type.label)" + (shift.otHours > 0 ? " + OT \(shift.otHours)ชม." : ""),
                category: shift.type.label,
                kind: .income,
                source: .shift,
                shiftType: shift.type
            )
        }
        transactions = (manualRows + derived).sorted { $0.date > $1.date }
        persist()
    }

    // MARK: - Derived selectors

    func shiftsInMonth(of date: Date) -> [Shift] {
        let cal = Calendar.gregorian
        let comps = cal.dateComponents([.year, .month], from: date)
        return shifts.filter {
            let c = cal.dateComponents([.year, .month], from: $0.date)
            return c.year == comps.year && c.month == comps.month
        }
    }

    func shiftCountsInMonth(of date: Date) -> [ShiftType: Int] {
        var counts: [ShiftType: Int] = [:]
        for s in shiftsInMonth(of: date) where s.type != .off {
            counts[s.type, default: 0] += 1
        }
        // OT is counted separately when otHours > 0 even if base type isn't .ot
        let otExtra = shiftsInMonth(of: date).filter { $0.otHours > 0 && $0.type != .ot }.count
        counts[.ot, default: 0] += otExtra
        return counts
    }

    func monthlyIncome(of date: Date) -> Int {
        transactionsInMonth(of: date)
            .filter { $0.kind == .income }
            .reduce(0) { $0 + $1.amount }
    }

    func monthlyExpense(of date: Date) -> Int {
        transactionsInMonth(of: date)
            .filter { $0.kind == .expense }
            .reduce(0) { $0 + abs($1.amount) }
    }

    func monthlyBalance(of date: Date) -> Int {
        monthlyIncome(of: date) - monthlyExpense(of: date)
    }

    func transactionsInMonth(of date: Date) -> [Transaction] {
        let cal = Calendar.gregorian
        let comps = cal.dateComponents([.year, .month], from: date)
        return transactions.filter {
            let c = cal.dateComponents([.year, .month], from: $0.date)
            return c.year == comps.year && c.month == comps.month
        }
    }

    /// Base shift pay only (OT hours are reported separately by `incomeFromOT`,
    /// so they must be excluded here to avoid double-counting).
    func incomeFromShifts(of date: Date) -> Int {
        shiftsInMonth(of: date)
            .filter { $0.type != .ot }
            .reduce(0) { sum, shift in
                let otPortion = shift.otHours * rates.otPerHour
                return sum + max(0, shift.income(using: rates) - otPortion)
            }
    }

    func incomeFromOT(of date: Date) -> Int {
        let monthShifts = shiftsInMonth(of: date)
        let otHoursIncome = monthShifts.reduce(0) { $0 + $1.otHours * rates.otPerHour }
        let otShiftCount = monthShifts.filter { $0.type == .ot }.count
        let otShiftIncome = otShiftCount * rates.morningShift
        return otHoursIncome + otShiftIncome
    }

    func activitiesOn(_ date: Date) -> [Activity] {
        activities
            .filter { Calendar.gregorian.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.time < $1.time }
    }

    func activitiesCount(of date: Date) -> Int {
        let cal = Calendar.gregorian
        let comps = cal.dateComponents([.year, .month], from: date)
        return activities.filter {
            let c = cal.dateComponents([.year, .month], from: $0.date)
            return c.year == comps.year && c.month == comps.month
        }.count
    }

    /// Past six months from the given anchor month (oldest first).
    func monthlyIncomeSeries(endingAt date: Date, length: Int = 6) -> [(Date, Int)] {
        let cal = Calendar.gregorian
        var series: [(Date, Int)] = []
        for offset in stride(from: length - 1, through: 0, by: -1) {
            if let d = cal.date(byAdding: .month, value: -offset, to: date) {
                series.append((d, monthlyIncome(of: d)))
            }
        }
        return series
    }
}
