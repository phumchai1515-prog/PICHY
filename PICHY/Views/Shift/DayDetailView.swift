//
//  DayDetailView.swift
//  PICHY
//
//  Hub for a single day: list every shift (a day can have several) and every
//  activity, with add / edit / delete. Shown when tapping a calendar day.
//

import SwiftUI

struct DayDetailView: View {
    @EnvironmentObject var store: AppStore
    let date: Date

    @State private var editingShift: Shift?
    @State private var showAddShift = false
    @State private var showAddActivity = false

    private var dayShifts: [Shift] { store.shifts(on: date) }
    private var dayActivities: [Activity] { store.activitiesOn(date) }
    private var dayIncome: Int {
        dayShifts.reduce(0) { $0 + $1.income(using: store.rates) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                hero
                shiftsSection
                activitiesSection
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .background(AppColors.bgScreen)
        .navigationTitle(BuddhistCalendar.dayMonthShort(date))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingShift) { shift in
            NavigationStack {
                AddEditShiftView(date: date, editing: shift).environmentObject(store)
            }
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddShift) {
            NavigationStack {
                AddEditShiftView(date: date).environmentObject(store)
            }
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddActivity) {
            NavigationStack {
                AddActivityView(date: date).environmentObject(store)
            }
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(BuddhistCalendar.fullDate(date))
                .font(AppFont.display(20, .semibold))
                .foregroundColor(.white)
            if dayIncome > 0 {
                Text("รายได้รวมวันนี้ \(CurrencyFormatter.baht(dayIncome))")
                    .font(AppFont.body(13, .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(AppColors.peachGradient))
        .heroShadow()
    }

    // MARK: - Shifts

    private var shiftsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("เวร (\(dayShifts.count))")

            VStack(spacing: 0) {
                if dayShifts.isEmpty {
                    emptyRow(icon: "calendar.badge.plus", text: "ยังไม่มีเวรในวันนี้")
                } else {
                    ForEach(Array(dayShifts.enumerated()), id: \.element.id) { idx, shift in
                        Button { editingShift = shift } label: { shiftRow(shift) }
                            .buttonStyle(.plain)
                        if idx < dayShifts.count - 1 {
                            Divider().background(AppColors.divider).padding(.leading, 60)
                        }
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white))
            .cardShadow()

            addButton(title: "เพิ่มเวร", icon: "calendar.badge.plus") { showAddShift = true }
        }
    }

    @ViewBuilder
    private func shiftRow(_ shift: Shift) -> some View {
        if let leave = shift.resolvedLeave {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(leave.tintBG)
                    Image(systemName: leave.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(leave.color)
                }
                .frame(width: 40, height: 40)
                Text(leave.label)
                    .font(AppFont.body(13, .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text(leave.hasQuota ? "นับโควต้า" : "ไม่นับโควต้า")
                    .font(AppFont.body(10, .semibold))
                    .foregroundColor(leave.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(leave.tintBG))
            }
            .padding(12)
            .contentShape(Rectangle())
        } else {
            HStack(spacing: 12) {
                ShiftSquareChip(type: shift.type, size: 40, radius: 12)
                VStack(alignment: .leading, spacing: 2) {
                    Text("เวร\(shift.type.label)" + (shift.otHours > 0 ? " + OT \(shift.otHours) ชม." : ""))
                        .font(AppFont.body(13, .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Text(shift.type.timeRange)
                        .font(AppFont.body(11, .regular))
                        .foregroundColor(AppColors.textMuted)
                }
                Spacer()
                Text(CurrencyFormatter.baht(shift.income(using: store.rates)))
                    .font(AppFont.display(14, .bold))
                    .foregroundColor(AppColors.incomeGreen)
            }
            .padding(12)
            .contentShape(Rectangle())
        }
    }

    // MARK: - Activities

    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("กิจกรรม (\(dayActivities.count))")

            VStack(spacing: 0) {
                if dayActivities.isEmpty {
                    emptyRow(icon: "list.bullet", text: "ยังไม่มีกิจกรรมในวันนี้")
                } else {
                    ForEach(Array(dayActivities.enumerated()), id: \.element.id) { idx, act in
                        activityRow(act)
                            .contextMenu {
                                Button(role: .destructive) { store.deleteActivity(act.id) } label: {
                                    Label("ลบกิจกรรม", systemImage: "trash")
                                }
                            }
                        if idx < dayActivities.count - 1 {
                            Divider().background(AppColors.divider).padding(.leading, 60)
                        }
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white))
            .cardShadow()

            addButton(title: "เพิ่มกิจกรรม", icon: "plus.circle.fill") { showAddActivity = true }
        }
    }

    private func activityRow(_ act: Activity) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous).fill(act.category.tintBG)
                Image(systemName: act.category.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(act.category.color)
            }
            .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(act.title)
                    .font(AppFont.body(13, .semibold))
                    .foregroundColor(AppColors.textPrimary)
                if let note = act.note, !note.isEmpty {
                    Text(note)
                        .font(AppFont.body(11, .regular))
                        .foregroundColor(AppColors.textMuted)
                }
            }
            Spacer()
            Text(act.time)
                .font(AppFont.display(13, .semibold))
                .foregroundColor(act.category.color)
        }
        .padding(12)
    }

    // MARK: - Shared bits

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(AppFont.body(12, .semibold))
            .foregroundColor(AppColors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }

    private func emptyRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .light))
                .foregroundColor(AppColors.textMuted)
            Text(text)
                .font(AppFont.body(12, .regular))
                .foregroundColor(AppColors.textMuted)
            Spacer()
        }
        .padding(16)
    }

    private func addButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(AppFont.body(14, .semibold))
            .foregroundColor(AppColors.peachPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(AppColors.surfacePeach))
        }
        .buttonStyle(.pressableScale)
    }
}
