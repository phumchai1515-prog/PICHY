//
//  BottomTabBar.swift
//  PICHY
//
//  Custom 4-tab bar with a center floating FAB.
//

import SwiftUI

struct BottomTabBar: View {
    @Binding var selectedTab: AppTab
    let onFABTap: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            // Bar
            HStack(spacing: 0) {
                tabButton(.calendar)
                tabButton(.wallet)
                Spacer().frame(width: 64)   // slot for FAB
                tabButton(.summary)
                tabButton(.profile)
            }
            .frame(height: 80)
            .background(
                AppColors.surfaceCard.opacity(0.97)
                    .overlay(
                        Rectangle()
                            .fill(AppColors.divider)
                            .frame(height: 1),
                        alignment: .top
                    )
                    .ignoresSafeArea(edges: .bottom)
            )

            // FAB
            Button(action: onFABTap) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppColors.peachGradient)
                        .frame(width: 56, height: 56)
                        .fabShadow()
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                .offset(y: -22)
            }
            .buttonStyle(.pressableScale)
        }
    }

    @ViewBuilder
    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            let isActive = selectedTab == tab
            VStack(spacing: 4) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 22, weight: .medium))
                Text(tab.label)
                    .font(AppFont.body(10, isActive ? .semibold : .medium))
            }
            .foregroundColor(isActive ? AppColors.peachActive : AppColors.textMutedNav)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
