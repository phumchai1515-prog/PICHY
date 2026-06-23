//
//  MonthlyActivitiesView.swift
//  PICHY
//

import SwiftUI

struct MonthlyActivitiesView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedDate: Date = Date()
    @State private var showAddActivity = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                        .padding(.horizontal, 20)

                    DateScroller(selected: $selectedDate, anchor: store.today)

                    Text(BuddhistCalendar.dateLabelMedium(selectedDate))
                        .font(AppFont.body(12, .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 20)

                    ActivityTimeline(items: store.activitiesOn(selectedDate))
                        .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.top, 12)
            }
            .background(AppColors.bgScreen)

            // Mini FAB to add activity
            Button(action: { showAddActivity = true }) {
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
        .onAppear { selectedDate = store.today }
        .sheet(isPresented: $showAddActivity) {
            NavigationStack {
                AddActivityView(date: selectedDate).environmentObject(store)
            }
            .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("กิจกรรมของฉัน")
                .font(AppFont.display(21, .semibold))
                .foregroundColor(AppColors.textPrimary)
            Text("\(BuddhistCalendar.monthYearLong(store.today)) · \(store.activitiesCount(of: store.today)) กิจกรรม")
                .font(AppFont.body(11, .regular))
                .foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack { MonthlyActivitiesView() }
        .environmentObject(AppStore())
}
