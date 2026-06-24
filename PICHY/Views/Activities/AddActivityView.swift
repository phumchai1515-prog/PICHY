//
//  AddActivityView.swift
//  PICHY
//
//  Add a schedule activity (time block) to a given day.
//

import SwiftUI

extension ActivityCategory {
    var label: String {
        switch self {
        case .morningShift: return "งานเวร"
        case .meeting:      return "ประชุม"
        case .ot:           return "OT"
        case .personal:     return "ส่วนตัว"
        }
    }
}

struct AddActivityView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let date: Date

    @State private var time: Date
    @State private var title: String = ""
    @State private var category: ActivityCategory = .personal
    @State private var note: String = ""

    init(date: Date) {
        self.date = date
        // Default the picker to 08:00 on the chosen day.
        let base = Calendar.gregorian.date(bySettingHour: 8, minute: 0, second: 0, of: date) ?? date
        _time = State(initialValue: base)
    }

    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ZStack {
            AppColors.bgScreen.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    timeCard
                    LabeledTextField(title: "ชื่อกิจกรรม", text: $title, placeholder: "เช่น ประชุมทีม, คลาสโยคะ")
                    categoryPicker
                    LabeledTextField(title: "บันทึก (ไม่บังคับ)", text: $note, placeholder: "รายละเอียดเพิ่มเติม")
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }

            VStack {
                Spacer()
                GradientButton(title: "เพิ่มกิจกรรม") { save() }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
            }
        }
        .navigationTitle("เพิ่มกิจกรรม")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var timeCard: some View {
        HStack {
            Text("เวลา")
                .font(AppFont.body(13, .semibold))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
        .cardShadow()
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ประเภท")
                .font(AppFont.body(12, .semibold))
                .foregroundColor(AppColors.textSecondary)
            HStack(spacing: 8) {
                ForEach(ActivityCategory.allCases, id: \.self) { cat in
                    Button { category = cat } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(cat.label)
                                .font(AppFont.body(12, .semibold))
                        }
                        .foregroundColor(category == cat ? .white : AppColors.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(
                            Capsule().fill(category == cat ? cat.color : Color.white)
                        )
                        .overlay(Capsule().stroke(AppColors.divider, lineWidth: category == cat ? 0 : 1))
                    }
                    .buttonStyle(.pressableScale)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func save() {
        let timeString = timeLabel(from: time)
        let activity = Activity(
            date: Calendar.gregorian.startOfDay(for: date),
            time: timeString,
            title: title.trimmingCharacters(in: .whitespaces),
            category: category,
            note: note.trimmingCharacters(in: .whitespaces).isEmpty ? nil : note
        )
        store.addActivity(activity)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }

    private func timeLabel(from date: Date) -> String {
        let c = Calendar.gregorian.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", c.hour ?? 0, c.minute ?? 0)
    }
}
