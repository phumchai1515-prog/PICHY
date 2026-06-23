//
//  ActivityTimeline.swift
//  PICHY
//

import SwiftUI

struct ActivityTimeline: View {
    let items: [Activity]

    var body: some View {
        if items.isEmpty {
            EmptyActivityCard()
        } else {
            VStack(spacing: 12) {
                ForEach(items) { item in
                    ActivityRow(activity: item)
                }
            }
        }
    }
}

private struct ActivityRow: View {
    let activity: Activity

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(activity.time)
                .font(AppFont.display(13, .semibold))
                .foregroundColor(activity.category.color)
                .frame(width: 48, alignment: .trailing)
                .padding(.top, 14)

            HStack(spacing: 0) {
                Rectangle()
                    .fill(activity.category.color)
                    .frame(width: 4)
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.title)
                        .font(AppFont.body(13, .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    if let note = activity.note {
                        Text(note)
                            .font(AppFont.body(11, .regular))
                            .foregroundColor(AppColors.textMuted)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .cardShadow()
        }
    }
}

private struct EmptyActivityCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(AppColors.textMuted)
            Text("ยังไม่มีกิจกรรมในวันนี้")
                .font(AppFont.body(13, .semibold))
                .foregroundColor(AppColors.textSecondary)
            Text("แตะปุ่ม + ด้านล่างเพื่อเพิ่ม")
                .font(AppFont.body(11, .regular))
                .foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .cardShadow()
    }
}
