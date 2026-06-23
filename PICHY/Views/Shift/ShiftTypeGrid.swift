//
//  ShiftTypeGrid.swift
//  PICHY
//

import SwiftUI

struct ShiftTypeGrid: View {
    @Binding var selected: ShiftType
    let types: [ShiftType]

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(types) { type in
                ShiftTypeCard(
                    type: type,
                    isSelected: selected == type
                )
                .onTapGesture { selected = type }
            }
        }
    }
}

private struct ShiftTypeCard: View {
    let type: ShiftType
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(type.tintBG)
                if type == .custom {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(type.textColor)
                } else if type == .off {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(type.textColor)
                } else {
                    Text(type.shortChip)
                        .font(AppFont.body(type.shortChip.count > 1 ? 11 : 14, .bold))
                        .foregroundColor(type.textColor)
                }
            }
            .frame(width: 34, height: 34)

            Text(type.label)
                .font(AppFont.body(13, .semibold))
                .foregroundColor(AppColors.textPrimary)

            Text(type.timeRange)
                .font(AppFont.body(10, .regular))
                .foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isSelected ? Color(hex: 0xEBA63F) : Color.clear,
                    lineWidth: 2
                )
        )
        .cardShadow()
    }
}
