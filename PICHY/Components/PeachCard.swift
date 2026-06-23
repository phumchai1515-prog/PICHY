//
//  PeachCard.swift
//  PICHY
//

import SwiftUI

struct PeachCard<Content: View>: View {
    var radius: CGFloat = 16
    var padding: CGFloat = 14
    var fill: Color = AppColors.surfaceCard
    var shadow: Bool = true
    @ViewBuilder var content: () -> Content

    var body: some View {
        let view = content()
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
            )
        if shadow {
            view.cardShadow()
        } else {
            view
        }
    }
}

struct CircleIconChip: View {
    let systemName: String
    var size: CGFloat = 40
    var radius: CGFloat = 13
    var bg: Color = AppColors.surfacePeach
    var fg: Color = AppColors.peachPrimary

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(bg)
            Image(systemName: systemName)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundColor(fg)
        }
        .frame(width: size, height: size)
    }
}
