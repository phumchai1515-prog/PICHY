//
//  NotificationDelegate.swift
//  PICHY
//
//  Without a delegate, iOS silently drops notification banners while the app is
//  in the foreground — so shift reminders looked like they "never fired". This
//  delegate tells the system to present them (banner + sound) even when PICHY is
//  open.
//

import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound, .badge]
    }
}
