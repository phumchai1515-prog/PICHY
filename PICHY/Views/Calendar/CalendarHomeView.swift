//
//  CalendarHomeView.swift
//  PICHY
//

import SwiftUI

struct CalendarHomeView: View {
    @EnvironmentObject var store: AppStore
    @State private var displayedMonth: Date = Calendar.gregorian.startOfMonth(for: Date())
    @State private var selectedDate: Date?
    @State private var showActivities = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CalendarHeader(
                    profile: store.profile,
                    anchor: store.today,
                    onBellTap: { showActivities = true }
                )
                .padding(.horizontal, 20)

                MonthSelectorCard(
                    month: displayedMonth,
                    shiftCount: store.shiftsInMonth(of: displayedMonth)
                        .filter { $0.type != .off }.count,
                    monthlyIncome: store.monthlyIncome(of: displayedMonth),
                    onPrev: { changeMonth(by: -1) },
                    onNext: { changeMonth(by: 1) }
                )
                .padding(.horizontal, 20)

                CalendarMonthGrid(
                    month: displayedMonth,
                    today: store.today,
                    shiftLookup: { date in store.shifts(on: date) },
                    onTapDay: { date in selectedDate = date }
                )
                .padding(.horizontal, 20)

                ShiftLegendRow(
                    counts: store.shiftCountsInMonth(of: displayedMonth)
                )
                .padding(.horizontal, 20)

                Spacer(minLength: 40)
            }
            .padding(.top, 12)
        }
        .background(AppColors.bgScreen)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showActivities) {
            MonthlyActivitiesView()
        }
        .sheet(item: selectedDateBinding) { dateBox in
            NavigationStack {
                DayDetailView(date: dateBox.date)
                    .environmentObject(store)
            }
            .presentationDragIndicator(.visible)
        }
    }

    private var selectedDateBinding: Binding<DateBox?> {
        Binding(
            get: { selectedDate.map(DateBox.init) },
            set: { selectedDate = $0?.date }
        )
    }

    private func changeMonth(by delta: Int) {
        if let next = Calendar.gregorian.date(byAdding: .month, value: delta, to: displayedMonth) {
            displayedMonth = next
        }
    }
}

private struct DateBox: Identifiable {
    let date: Date
    var id: TimeInterval { date.timeIntervalSince1970 }
}

#Preview {
    NavigationStack { CalendarHomeView() }
        .environmentObject(AppStore())
}
