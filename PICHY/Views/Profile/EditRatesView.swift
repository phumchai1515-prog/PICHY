//
//  EditRatesView.swift
//  PICHY
//
//  Edit pay rates. Changing rates re-derives all shift income automatically.
//

import SwiftUI

struct EditRatesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var dayShift: Int
    @State private var nightShift: Int
    @State private var otPerHour: Int

    init(rates: PayRates) {
        _dayShift = State(initialValue: rates.dayShift)
        _nightShift = State(initialValue: rates.nightShift)
        _otPerHour = State(initialValue: rates.otPerHour)
    }

    var body: some View {
        ZStack {
            AppColors.bgScreen.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    Text("ค่าเวรของแต่ละโรงพยาบาลไม่เท่ากัน\nปรับให้ตรงกับของคุณเพื่อคำนวณรายได้ที่ถูกต้อง")
                        .font(AppFont.body(13, .regular))
                        .foregroundColor(AppColors.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    VStack(spacing: 0) {
                        AmountField(type: .morning, label: "เวรเช้า/บ่าย", amount: $dayShift)
                        Divider().background(AppColors.divider).padding(.leading, 60)
                        AmountField(type: .night, label: "เวรดึก", amount: $nightShift)
                        Divider().background(AppColors.divider).padding(.leading, 60)
                        AmountField(type: .ot, label: "OT ต่อชั่วโมง", amount: $otPerHour)
                    }
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white))
                    .cardShadow()
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }

            VStack {
                Spacer()
                GradientButton(title: "บันทึก") {
                    store.updateRates(PayRates(dayShift: dayShift, nightShift: nightShift, otPerHour: otPerHour))
                    dismiss()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .navigationTitle("อัตราค่าเวร")
        .navigationBarTitleDisplayMode(.inline)
    }
}
