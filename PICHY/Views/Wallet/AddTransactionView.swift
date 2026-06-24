//
//  AddTransactionView.swift
//  PICHY
//
//  Add a manual income or expense entry to the wallet.
//

import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var kind: TransactionKind = .expense
    @State private var amount: Int = 0
    @State private var title: String = ""
    @State private var category: ExpenseCategory = .food
    @State private var date: Date
    @State private var note: String = ""

    init(date: Date = Date()) {
        _date = State(initialValue: date)
    }

    private var canSave: Bool {
        amount > 0 && !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.bgScreen.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    kindPicker
                    amountCard
                    LabeledTextField(title: "ชื่อรายการ", text: $title,
                                     placeholder: kind == .expense ? "เช่น ค่าข้าว, ค่าเดินทาง" : "เช่น โบนัส, รายได้พิเศษ")
                    if kind == .expense { categoryPicker }
                    dateCard
                    LabeledTextField(title: "บันทึก (ไม่บังคับ)", text: $note, placeholder: "รายละเอียดเพิ่มเติม")
                    Spacer(minLength: 90)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }

            GradientButton(title: kind == .expense ? "เพิ่มรายจ่าย" : "เพิ่มรายรับ") { save() }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
        }
        .navigationTitle("เพิ่มรายการ")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var kindPicker: some View {
        HStack(spacing: 10) {
            kindButton(.expense, label: "รายจ่าย", color: AppColors.expenseRose)
            kindButton(.income, label: "รายรับ", color: AppColors.incomeGreen)
        }
    }

    private func kindButton(_ k: TransactionKind, label: String, color: Color) -> some View {
        Button { kind = k } label: {
            Text(label)
                .font(AppFont.body(14, .semibold))
                .foregroundColor(kind == k ? .white : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(kind == k ? color : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppColors.divider, lineWidth: kind == k ? 0 : 1)
                )
        }
        .buttonStyle(.pressableScale)
    }

    private var amountCard: some View {
        HStack {
            Text("จำนวนเงิน")
                .font(AppFont.body(13, .semibold))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            HStack(spacing: 4) {
                Text("฿")
                    .font(AppFont.display(16, .semibold))
                    .foregroundColor(AppColors.textMuted)
                TextField("0", value: $amount, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(AppFont.display(18, .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 110)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(AppColors.surfacePeach))
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
        .cardShadow()
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("หมวดหมู่")
                .font(AppFont.body(12, .semibold))
                .foregroundColor(AppColors.textSecondary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                    Button { category = cat } label: {
                        HStack(spacing: 6) {
                            Image(systemName: cat.iconName)
                                .font(.system(size: 12, weight: .semibold))
                            Text(cat.label)
                                .font(AppFont.body(12, .semibold))
                        }
                        .foregroundColor(category == cat ? .white : AppColors.textSecondary)
                        .padding(.horizontal, 12).padding(.vertical, 9)
                        .frame(maxWidth: .infinity)
                        .background(Capsule().fill(category == cat ? AppColors.peachPrimary : Color.white))
                        .overlay(Capsule().stroke(AppColors.divider, lineWidth: category == cat ? 0 : 1))
                    }
                    .buttonStyle(.pressableScale)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var dateCard: some View {
        HStack {
            Text("วันที่")
                .font(AppFont.body(13, .semibold))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "th_TH"))
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white))
        .cardShadow()
    }

    private func save() {
        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
        let signedAmount = kind == .expense ? -abs(amount) : abs(amount)
        let transaction = Transaction(
            date: date,
            amount: signedAmount,
            title: title.trimmingCharacters(in: .whitespaces),
            category: kind == .expense ? category.label : "รายรับ",
            kind: kind,
            source: .manual,
            note: trimmedNote.isEmpty ? nil : trimmedNote
        )
        store.addTransaction(transaction)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
    }
}
