//
//  LeaveSummaryCard.swift
//  PICHY
//
//  Shows this month's off/leave days and quota usage for the current fiscal year.
//

import SwiftUI

struct LeaveSummaryCard: View {
    @EnvironmentObject var store: AppStore

    private var anchor: Date { store.today }
    private var monthLeaves: [Shift] { store.leaveDaysInMonth(of: anchor) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            monthSection
            Divider().background(AppColors.divider)
            quotaSection
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white))
        .cardShadow()
    }

    private var header: some View {
        HStack {
            Text("วันหยุด / วันลา")
                .font(AppFont.display(15, .semibold))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Text(FiscalYear.label(containing: anchor))
                .font(AppFont.body(10, .semibold))
                .foregroundColor(AppColors.textMuted)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Capsule().fill(AppColors.surfacePeach))
        }
    }

    // MARK: - This month

    @ViewBuilder
    private var monthSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("เดือนนี้หยุด/ลา \(monthLeaves.count) วัน")
                .font(AppFont.body(13, .semibold))
                .foregroundColor(AppColors.textSecondary)

            if monthLeaves.isEmpty {
                Text("ยังไม่มีวันหยุด/ลาในเดือนนี้")
                    .font(AppFont.body(12, .regular))
                    .foregroundColor(AppColors.textMuted)
            } else {
                FlowChips(items: monthLeaves)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Quota

    private var quotaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("โควต้าวันลา (ทั้งปีงบประมาณ)")
                .font(AppFont.body(12, .semibold))
                .foregroundColor(AppColors.textSecondary)

            ForEach(LeaveType.quotaKinds) { kind in
                quotaRow(kind)
            }
        }
    }

    private func quotaRow(_ kind: LeaveType) -> some View {
        let total = store.quota.days(for: kind)
        let used = store.leaveUsed(kind, inFiscalYearOf: anchor)
        let remaining = max(0, total - used)
        let fraction = total > 0 ? min(1, Double(used) / Double(total)) : 0
        return VStack(alignment: .leading, spacing: 5) {
            HStack {
                Circle().fill(kind.color).frame(width: 8, height: 8)
                Text(kind.label)
                    .font(AppFont.body(12, .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("ใช้ \(used)/\(total) · เหลือ \(remaining)")
                    .font(AppFont.body(11, .semibold))
                    .foregroundColor(remaining == 0 ? AppColors.expenseRose : AppColors.textSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(kind.tintBG).frame(height: 6)
                    Capsule().fill(kind.color).frame(width: geo.size.width * fraction, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

/// Wraps day-number chips for the month's leave days.
private struct FlowChips: View {
    let items: [Shift]

    private let columns = [GridItem(.adaptive(minimum: 64), spacing: 8)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(items) { shift in
                let leave = shift.resolvedLeave ?? .dayOff
                HStack(spacing: 5) {
                    Text("\(Calendar.gregorian.component(.day, from: shift.date))")
                        .font(AppFont.display(12, .bold))
                    Text(leave.shortLabel)
                        .font(AppFont.body(10, .semibold))
                }
                .foregroundColor(leave.color)
                .padding(.horizontal, 8).padding(.vertical, 5)
                .background(Capsule().fill(leave.tintBG))
            }
        }
    }
}
