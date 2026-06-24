//
//  CalendarDayCell.swift
//  PICHY
//

import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isToday: Bool
    let shifts: [Shift]
    var height: CGFloat = 45
    let onTap: () -> Void

    /// Shifts that count as "work" (drive the tint and chips).
    private var workShifts: [Shift] {
        shifts.filter { $0.type != .off }
    }

    private var primary: Shift? { workShifts.first ?? shifts.first }
    private var primaryLeave: LeaveType? { primary?.resolvedLeave }
    private var hasOT: Bool { shifts.contains { $0.otHours > 0 || $0.type == .ot } }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                cellBackground
                    .overlay(
                        VStack(spacing: 3) {
                            Text("\(dayNumber)")
                                .font(AppFont.display(dayFontSize, .semibold))
                                .foregroundColor(numberColor)
                            shiftChips
                        }
                    )
                if hasOT {
                    Circle()
                        .fill(ShiftType.ot.dot)
                        .frame(width: dotSize, height: dotSize)
                        .padding(5)
                }
            }
            .frame(height: height)
        }
        .buttonStyle(.pressableScale)
    }

    private var dayNumber: Int {
        Calendar.gregorian.component(.day, from: date)
    }

    /// Font sizes scale with cell height so larger cells stay balanced.
    private var dayFontSize: CGFloat { (height * 0.28).clamped(to: 13...22) }
    private var chipFontSize: CGFloat { (height * 0.21).clamped(to: 9...15) }
    private var dotSize: CGFloat { (height * 0.16).clamped(to: 7...11) }

    private var numberColor: Color {
        if isToday { return AppColors.peachActive }
        if let leave = primaryLeave { return leave.color }
        if let primary, primary.type != .off { return primary.type.textColor }
        return AppColors.textPrimary
    }

    /// Up to two short chips; a third+ shift collapses into a "+N" marker.
    @ViewBuilder
    private var shiftChips: some View {
        if workShifts.isEmpty {
            if let leave = primaryLeave {
                Text(leave.shortLabel)
                    .font(AppFont.body(chipFontSize, .bold))
                    .foregroundColor(leave.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        } else {
            HStack(spacing: 3) {
                ForEach(Array(workShifts.prefix(2).enumerated()), id: \.offset) { _, s in
                    Text(s.type.shortChip)
                        .font(AppFont.body(chipFontSize, .bold))
                        .foregroundColor(s.type.textColor)
                }
                if workShifts.count > 2 {
                    Text("+\(workShifts.count - 2)")
                        .font(AppFont.body(chipFontSize - 1, .bold))
                        .foregroundColor(AppColors.textMuted)
                }
            }
        }
    }

    @ViewBuilder
    private var cellBackground: some View {
        let radius: CGFloat = 13
        if isToday {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(AppColors.peachActive, lineWidth: 2)
                )
                .heroShadow()
        } else if let leave = primaryLeave {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(leave.tintBG)
        } else if let primary {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(primary.type.tintBG)
        } else {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.white)
        }
    }
}
