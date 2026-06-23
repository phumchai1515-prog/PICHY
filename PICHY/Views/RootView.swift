//
//  RootView.swift
//  PICHY
//

import SwiftUI

enum AppTab: Int, Hashable, CaseIterable {
    case calendar, wallet, summary, profile

    var iconName: String {
        switch self {
        case .calendar: return "calendar"
        case .wallet:   return "creditcard.fill"
        case .summary:  return "chart.bar.fill"
        case .profile:  return "person.fill"
        }
    }

    var label: String {
        switch self {
        case .calendar: return "ปฏิทิน"
        case .wallet:   return "รายรับจ่าย"
        case .summary:  return "สรุป"
        case .profile:  return "โปรไฟล์"
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedTab: AppTab = .calendar
    @State private var presentAddShift = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.bgScreen.ignoresSafeArea()

            screen(for: selectedTab)
                .padding(.bottom, 78) // reserve space for the tab bar

            BottomTabBar(
                selectedTab: $selectedTab,
                onFABTap: { presentAddShift = true }
            )
        }
        .sheet(isPresented: $presentAddShift) {
            NavigationStack {
                AddEditShiftView(date: store.today)
                    .environmentObject(store)
            }
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private func screen(for tab: AppTab) -> some View {
        switch tab {
        case .calendar:
            NavigationStack { CalendarHomeView() }
        case .wallet:
            NavigationStack { IncomeExpenseView() }
        case .summary:
            NavigationStack { SummaryStatsView() }
        case .profile:
            NavigationStack { ProfileSettingsView() }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppStore())
        .environmentObject(AuthManager())
}
