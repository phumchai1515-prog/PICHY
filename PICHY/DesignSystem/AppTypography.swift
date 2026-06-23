//
//  AppTypography.swift
//  PICHY
//
//  System fonts only. Prompt/Anuphan can be bundled later; weight + size mapping
//  preserved so swapping is a one-line change per style.
//

import SwiftUI

enum AppFont {
    // "Display" family — used for headings, big numbers, currency, day numbers.
    static func display(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    // "Body" family — labels, captions, body text.
    static func body(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

extension View {
    func screenH1() -> some View {
        font(AppFont.display(28, .semibold))
            .tracking(-0.5)
            .foregroundColor(AppColors.textPrimary)
    }

    func screenTitle() -> some View {
        font(AppFont.display(20, .semibold))
            .foregroundColor(AppColors.textPrimary)
    }

    func sectionLabel() -> some View {
        font(AppFont.body(12, .semibold))
            .foregroundColor(AppColors.textSecondary)
    }

    func rowLabel() -> some View {
        font(AppFont.body(13, .semibold))
            .foregroundColor(AppColors.textPrimary)
    }

    func caption() -> some View {
        font(AppFont.body(11, .regular))
            .foregroundColor(AppColors.textMuted)
    }
}
