//
//  IncomeExpenseView.swift
//  PICHY
//

import SwiftUI

struct IncomeExpenseView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAddTransaction = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 16) {
                    BalanceHero(
                        balance: store.monthlyBalance(of: store.today),
                        income: store.monthlyIncome(of: store.today),
                        expense: store.monthlyExpense(of: store.today)
                    )
                    .padding(.horizontal, 20)

                    HStack {
                        Text("รายการเดือนนี้")
                            .font(AppFont.display(15, .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Text("\(store.transactionsInMonth(of: store.today).count) รายการ")
                            .font(AppFont.body(12, .semibold))
                            .foregroundColor(AppColors.textMuted)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                    if groupedTransactions.isEmpty {
                        emptyState
                    } else {
                        TransactionsGroupedList(groups: groupedTransactions)
                            .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 90)
                }
                .padding(.top, 16)
            }
            .background(AppColors.bgScreen)

            Button(action: { showAddTransaction = true }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.peachGradient)
                        .frame(width: 54, height: 54)
                        .fabShadow()
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.pressableScale)
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddTransaction) {
            NavigationStack {
                AddTransactionView(date: store.today).environmentObject(store)
            }
            .presentationDragIndicator(.visible)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(AppColors.textMuted)
            Text("ยังไม่มีรายการในเดือนนี้")
                .font(AppFont.body(13, .semibold))
                .foregroundColor(AppColors.textSecondary)
            Text("แตะปุ่ม + เพื่อเพิ่มรายรับ/รายจ่าย")
                .font(AppFont.body(11, .regular))
                .foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .padding(.horizontal, 20)
    }

    private var groupedTransactions: [(label: String, items: [Transaction])] {
        let cal = Calendar.gregorian
        let txs = store.transactionsInMonth(of: store.today)
        let grouped = Dictionary(grouping: txs) { cal.startOfDay(for: $0.date) }
        let sortedDays = grouped.keys.sorted(by: >)
        return sortedDays.map { day -> (String, [Transaction]) in
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
