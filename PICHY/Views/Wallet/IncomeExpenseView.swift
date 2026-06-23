//
//  IncomeExpenseView.swift
//  PICHY
//

import SwiftUI

struct IncomeExpenseView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                BalanceHero(
                    balance: store.monthlyBalance(of: store.today),
                    income: store.monthlyIncome(of: store.today),
                    expense: store.monthlyExpense(of: store.today)
                )
                .padding(.horizontal, 20)

                HStack {
                    Text("รายการล่าสุด")
                        .font(AppFont.display(15, .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Text("ทั้งหมด")
                        .font(AppFont.body(12, .semibold))
                        .foregroundColor(AppColors.peachActive)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)

                TransactionsGroupedList(
                    groups: groupedTransactions
                )
                .padding(.horizontal, 20)

                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .background(AppColors.bgScreen)
        .navigationBarHidden(true)
    }

    private var groupedTransactions: [(label: String, items: [Transaction])] {
        let cal = Calendar.gregorian
        let txs = store.transactionsInMonth(of: store.today)
        let grouped = Dictionary(grouping: txs) { cal.startOfDay(for: $0.date) }
        let sortedDays = grouped.keys.sorted(by: >)
        return sortedDays.prefix(3).map { day -> (String, [Transaction]) in
            let label: String
            if cal.isDate(day, inSameDayAs: store.today) {
                label = "วันนี้ · \(BuddhistCalendar.dayMonthShort(day))"
            } else if cal.isDate(day, inSameDayAs: cal.date(byAdding: .day, value: -1, to: store.today) ?? day) {
                label = "เมื่อวาน · \(BuddhistCalendar.dayMonthShort(day))"
            } else {
                label = BuddhistCalendar.dayMonthShort(day)
            }
            return (label, grouped[day] ?? [])
        }
    }
}

#Preview {
    NavigationStack { IncomeExpenseView() }
        .environmentObject(AppStore())
}
