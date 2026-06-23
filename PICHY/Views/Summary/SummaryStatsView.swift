//
//  SummaryStatsView.swift
//  PICHY
//

import SwiftUI

struct SummaryStatsView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                    .padding(.horizontal, 20)

                BarChartCard(series: store.monthlyIncomeSeries(endingAt: store.today))
                    .padding(.horizontal, 20)

                DonutBreakdownCard(
                    counts: store.shiftCountsInMonth(of: store.today)
                )
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    StatTile(
                        title: "รายได้จากเวร",
                        amount: store.incomeFromShifts(of: store.today),
                        tint: Color(hex: 0xFAEBD3),
                        textColor: Color(hex: 0xA77B23)
                    )
                    StatTile(
                        title: "รายได้ OT",
                        amount: store.incomeFromOT(of: store.today),
                        tint: Color(hex: 0xFAE3EB),
                        textColor: Color(hex: 0xCE5079)
                    )
                }
                .padding(.horizontal, 20)

                LeaveSummaryCard()
                    .padding(.horizontal, 20)

                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .background(AppColors.bgScreen)
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("สรุปเดือนนี้")
                .font(AppFont.display(21, .semibold))
                .foregroundColor(AppColors.textPrimary)
            Text(BuddhistCalendar.monthYearLong(store.today))
                .font(AppFont.body(11, .regular))
                .foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct StatTile: View {
    let title: String
    let amount: Int
    let tint: Color
    let textColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFont.body(11, .regular))
                .foregroundColor(textColor.opacity(0.8))
            Text(CurrencyFormatter.baht(amount))
                .font(AppFont.display(20, .bold))
                .foregroundColor(textColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(tint)
        )
    }
}

#Preview {
    NavigationStack { SummaryStatsView() }
        .environmentObject(AppStore())
}
