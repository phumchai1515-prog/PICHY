//
//  GradientButton.swift
//  PICHY
//

import SwiftUI

struct GradientButton: View {
    let title: String
    let action: () -> Void
    var height: CGFloat = 52
    var cornerRadius: CGFloat = 18

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.display(16, .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(AppColors.peachGradient)
                )
                .heroShadow()
        }
        .buttonStyle(.pressableScale)
    }
}
