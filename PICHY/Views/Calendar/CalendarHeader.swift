//
//  CalendarHeader.swift
//  PICHY
//

import SwiftUI

struct CalendarHeader: View {
    let profile: UserProfile
    let anchor: Date
    var onBellTap: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            AvatarView(profile: profile, size: 44, cornerRadius: 15)

            VStack(alignment: .leading, spacing: 2) {
                Text(BuddhistCalendar.greeting(for: anchor))
                    .font(AppFont.body(12, .regular))
                    .foregroundColor(AppColors.textMuted)
                Text(profile.name)
                    .font(AppFont.display(16, .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }

            Spacer()

            // Bell — taps open Activities
            Button(action: onBellTap) {
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                            .cardShadow()
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    Circle()
                        .fill(AppColors.notificationDot)
                        .frame(width: 9, height: 9)
                        .offset(x: 3, y: -3)
                }
            }
            .buttonStyle(.pressableScale)
        }
    }
}
