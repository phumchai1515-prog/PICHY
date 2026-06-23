//
//  AppColors.swift
//  PICHY
//

import SwiftUI

enum AppColors {
    // Brand / Surfaces
    static let peachGradientFrom = Color(hex: 0xFFB089)
    static let peachGradientTo   = Color(hex: 0xE5613B)
    static let peachPrimary      = Color(hex: 0xE96E4C)
    static let peachActive       = Color(hex: 0xE5613B)

    static let bgApp        = Color(hex: 0xECE3DB)
    static let bgScreen     = Color(hex: 0xFCF6F0)
    static let surfaceCard  = Color.white
    static let surfacePeach = Color(hex: 0xFBEDE4)
    static let divider      = Color(hex: 0xF1E5DB)

    // Text
    static let textPrimary   = Color(hex: 0x3C2E26)
    static let textSecondary = Color(hex: 0x7C6A5D)
    static let textMuted     = Color(hex: 0xA18A7C)
    static let textMutedNav  = Color(hex: 0xB6A498)

    // Semantic
    static let incomeGreen      = Color(hex: 0x329F61)
    static let expenseRose      = Color(hex: 0xCE5079)
    static let notificationDot  = Color(hex: 0xEC6E95)

    // Toggle off track
    static let toggleOffTrack = Color(hex: 0xE6D8CD)

    // Gradients
    static let peachGradient = LinearGradient(
        colors: [peachGradientFrom, peachGradientTo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
