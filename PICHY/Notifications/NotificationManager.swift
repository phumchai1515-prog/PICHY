//
//  NotificationManager.swift
//  PICHY
//
//  Schedules local notifications for upcoming shifts (an "alarm" a configurable
//  lead time before each shift) plus an optional nightly summary of tomorrow's
//  shift. iOS local notifications can carry a sound but cannot override silent
//  mode the way the system Clock alarm does.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let shiftPrefix = "pichy.shift."
    private let summaryPrefix = "pichy.summary."

    /// Don't schedule more than this many future days to stay well under the
    /// 64 pending-notification limit iOS enforces per app.
    private let horizonDays = 30

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // MARK: - Scheduling

    /// Cancels and re-creates all shift reminders from the current data.
    /// Safe to call on every shift/settings change.
    func reschedule(shifts: [Shift], settings: AppSettings, from now: Date) {
        cancelAll()
        guard settings.shiftReminder else { return }

        let cal = Calendar.gregorian
        let horizon = cal.date(byAdding: .day, value: horizonDays, to: now) ?? now
        let upcoming = shifts
            .filter { $0.type != .off && $0.type != .custom }
            .sorted { $0.date < $1.date }

        for shift in upcoming {
            scheduleShiftReminder(shift, settings: settings, now: now, horizon: horizon, cal: cal)
            if settings.nightlySummary {
                scheduleNightlySummary(shift, now: now, horizon: horizon, cal: cal)
            }
        }
    }

    func cancelAll() {
        // Only remove our shift/summary requests, leaving any test alert intact.
        center.getPendingNotificationRequests { reqs in
            let ids = reqs.map(\.identifier).filter {
                $0.hasPrefix(self.shiftPrefix) || $0.hasPrefix(self.summaryPrefix)
            }
            self.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    /// Number of scheduled shift reminders currently pending.
    func pendingShiftCount() async -> Int {
        let reqs = await center.pendingNotificationRequests()
        return reqs.filter { $0.identifier.hasPrefix(shiftPrefix) }.count
    }

    /// Fires a sample alert a few seconds out so the user can confirm it works.
    func scheduleTest(after seconds: TimeInterval = 8) {
        let content = UNMutableNotificationContent()
        content.title = "ทดสอบแจ้งเตือน PICHY"
        content.body = "ถ้าเห็นข้อความนี้ แปลว่าการแจ้งเตือนทำงานปกติ ✓"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        center.add(UNNotificationRequest(identifier: "pichy.test", content: content, trigger: trigger))
    }

    // MARK: - Builders

    private func scheduleShiftReminder(_ shift: Shift,
                                       settings: AppSettings,
                                       now: Date,
                                       horizon: Date,
                                       cal: Calendar) {
        guard let start = shiftStart(for: shift, cal: cal) else { return }
        guard let fireDate = cal.date(byAdding: .minute, value: -settings.reminderLead.rawValue, to: start) else { return }
        guard fireDate > now, fireDate <= horizon else { return }

        let content = UNMutableNotificationContent()
        content.title = "ใกล้ถึงเวลาเข้าเวร"
        content.body = "เวร\(shift.type.label) เริ่ม \(shift.type.timeRange) — อีก \(settings.reminderLead.label)"
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        add(content, fireDate: fireDate, cal: cal, id: shiftPrefix + shift.id.uuidString)
    }

    private func scheduleNightlySummary(_ shift: Shift,
                                        now: Date,
                                        horizon: Date,
                                        cal: Calendar) {
        // Fire at 21:00 the evening before the shift.
        guard let start = shiftStart(for: shift, cal: cal) else { return }
        guard let eveningBefore = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: start)),
              let fireDate = cal.date(bySettingHour: 21, minute: 0, second: 0, of: eveningBefore) else { return }
        guard fireDate > now, fireDate <= horizon else { return }

        let content = UNMutableNotificationContent()
        content.title = "เวรพรุ่งนี้"
        content.body = "พรุ่งนี้มีเวร\(shift.type.label) (\(shift.type.timeRange))"
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        add(content, fireDate: fireDate, cal: cal, id: summaryPrefix + shift.id.uuidString)
    }

    private func add(_ content: UNMutableNotificationContent, fireDate: Date, cal: Calendar, id: String) {
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    private func shiftStart(for shift: Shift, cal: Calendar) -> Date? {
        guard let t = shift.type.startTime else { return nil }
        return cal.date(bySettingHour: t.hour, minute: t.minute, second: 0, of: shift.date)
    }
}
