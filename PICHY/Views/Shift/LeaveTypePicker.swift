//
//  LeaveTypePicker.swift
//  PICHY
//
//  Choose which kind of day-off / leave a `.off` day represents.
//

import SwiftUI

struct LeaveTypePicker: View {
    @Binding var selected: LeaveType

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ประเภทวันหยุด/ลา")
                .font(AppFont.body(12, .semibold))
                .foregroundColor(AppColors.textSecondary)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(LeaveType.allCases) { kind in
                    Button { selected = kind } label: { tile(kind) }
                        .buttonStyle(.pressableScale)
                }
            }
        }
    }

    private func tile(_ kind: LeaveType) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous).fill(kind.tintBG)
                Image(systemName: kind.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(kind.color)
            }
            .frame(width: 34, height: 34)

            Text(kind.label)
                .font(AppFont.body(12, .semibold))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(selected == kind ? kind.color : Color.clear, lineWidth: 2)
        )
        .cardShadow()
    }
}
