//
//  AppShadows.swift
//  PICHY
//

import SwiftUI

enum AppShadow {
    static func card<V: View>(_ view: V) -> some View {
        view.shadow(color: Color(hex: 0x3C2E26, alpha: 0.10),
                    radius: 8, x: 0, y: 4)
    }

    static func hero<V: View>(_ view: V) -> some View {
        view.shadow(color: Color(hex: 0xE5614C, alpha: 0.35),
                    radius: 14, x: 0, y: 10)
    }

    static func fab<V: View>(_ view: V) -> some View {
        view.shadow(color: Color(hex: 0xE5614C, alpha: 0.45),
                    radius: 10, x: 0, y: 6)
    }
}

extension View {
    func cardShadow() -> some View { AppShadow.card(self) }
    func heroShadow() -> some View { AppShadow.hero(self) }
    func fabShadow()  -> some View { AppShadow.fab(self) }
}
