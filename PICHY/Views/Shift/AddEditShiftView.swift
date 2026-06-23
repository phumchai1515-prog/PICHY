//
//  AddEditShiftView.swift
//  PICHY
//

import SwiftUI

struct AddEditShiftView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let date: Date
    /// When set, the view edits this shift; otherwise it adds a new one.
    var editing: Shift? = nil

    @State private var selectedType: ShiftType = .morning
    @State private var otEnabled: Bool = false
    @State private var otHours: Int = 2
    @State private var selectedLeave: LeaveType = .dayOff
    @State private var rangeEnabled: Bool = false
    @State private var endDate: Date

    private var isEditing: Bool { editing != nil }
    private var isLeave: Bool { selectedType == .off }
    /// Range mode is only offered when adding a fresh leave block.
    private var canUseRange: Bool { isLeave && !isEditing }
    private var rangeDayCount: Int {
        let cal = Calendar.gregorian
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: date),
                                      to: cal.startOfDay(for: endDate)).day ?? 0
        return max(1, days + 1)
    }

    init(date: Date, editing: Shift? = nil) {
        self.date = date
        self.editing = editing
        _endDate = State(initialValue: date)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 16) {
                    DateHeroCard(date: date)

                    Text("เลือกประเภทเวร")
                        .font(AppFont.body(12, .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)

                    ShiftTypeGrid(
                        selected: $selectedType,
                        types: ShiftType.allCases
                    )

                    if isLeave {
                        LeaveTypePicker(selected: $selectedLeave)
                        if canUseRange { rangeCard }
                    } else {
                        ShiftDetailCard(otEnabled: $otEnabled, otHours: $otHours, type: selectedType)
                    }

                    IncomePreviewCard(
                        type: selectedType,
                        otHours: otEnabled ? otHours : 0,
                        rates: store.rates
                    )

                    if isEditing {
                        Button(role: .destructive) {
                            if let editing { store.deleteShift(editing.id) }
                            dismiss()
                        } label: {
                            Label("ลบเวรนี้", systemImage: "trash")
                                .font(AppFont.body(14, .semibold))
                                .foregroundColor(AppColors.expenseRose)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(AppColors.expenseRose.opacity(0.1))
                                )
                        }
                        .buttonStyle(.pressableScale)
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .background(AppColors.bgScreen)

            // Save button pinned bottom
            GradientButton(title: saveTitle) {
                save()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                dismiss()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .navigationTitle(isEditing ? "แก้ไขเวร" : "เพิ่มเวร")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.bgScreen, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear { loadExisting() }
    }

    private var saveTitle: String {
        if canUseRange && rangeEnabled { return "บันทึกวันหยุด \(rangeDayCount) วัน" }
        if isEditing { return "บันทึกการแก้ไข" }
        return isLeave ? "เพิ่มวันหยุด" : "เพิ่มเวร"
    }

    private func save() {
        if canUseRange && rangeEnabled {
            store.setLeaveRange(from: date, to: endDate, leaveType: selectedLeave)
            return
        }
        let shift = Shift(
            id: editing?.id ?? UUID(),
            date: date,
            type: selectedType,
            otHours: (isLeave ? 0 : (otEnabled ? otHours : 0)),
            leaveType: isLeave ? selectedLeave : nil
        )
        store.upsertShift(shift)
    }

    private var rangeCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                CircleIconChip(systemName: "calendar.badge.plus", size: 36, radius: 11)
                VStack(alignment: .leading, spacing: 2) {
                    Text("หยุดหลายวัน")
                        .font(AppFont.body(13, .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("เลือกช่วงวันแล้วกดครั้งเดียว")
                        .font(AppFont.body(11, .regular))
                        .foregroundColor(AppColors.textMuted)
                }
                Spacer()
                PeachToggle(isOn: $rangeEnabled)
            }
            .padding(14)

            if rangeEnabled {
                Divider().background(AppColors.divider).padding(.horizontal, 14)
                HStack {
                    Text("ตั้งแต่")
                        .font(AppFont.body(12, .regular))
                        .foregroundColor(AppColors.textMuted)
                    Text(BuddhistCalendar.dayMonthShort(date))
                        .font(AppFont.body(13, .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 14).padding(.vertical, 10)

                Divider().background(AppColors.divider).padding(.horizontal, 14)
                HStack {
                    Text("ถึงวันที่")
                        .font(AppFont.body(13, .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    DatePicker("", selection: $endDate, in: date..., displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "th_TH"))
                }
                .padding(.horizontal, 14).padding(.vertical, 10)

                HStack {
                    Spacer()
                    Text("รวม \(rangeDayCount) วัน")
                        .font(AppFont.body(12, .semibold))
                        .foregroundColor(selectedLeave.color)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Capsule().fill(selectedLeave.tintBG))
                    Spacer()
                }
                .padding(.bottom, 12)
            }
        }
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white))
        .cardShadow()
    }

    private func loadExisting() {
        guard let existing = editing else { return }
        selectedType = existing.type
        otEnabled = existing.otHours > 0
        otHours = max(existing.otHours, 1)
        selectedLeave = existing.resolvedLeave ?? .dayOff
    }
}

private struct DateHeroCard: View {
    let date: Date
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("วันที่เลือก")
                .font(AppFont.body(12, .regular))
                .foregroundColor(.white.opacity(0.85))
            Text(BuddhistCalendar.fullDate(date))
                .font(AppFont.display(22, .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.peachGradient)
        )
        .heroShadow()
    }
}

#Preview {
    NavigationStack {
        AddEditShiftView(date: Date())
            .environmentObject(AppStore())
    }
}
