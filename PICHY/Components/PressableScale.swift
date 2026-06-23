//
//  PressableScale.swift
//  PICHY
//

import SwiftUI

struct PressableScaleStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableScaleStyle {
    static var pressableScale: PressableScaleStyle { PressableScaleStyle() }
}
