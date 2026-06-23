//
//  PeachToggle.swift
//  PICHY
//

import SwiftUI

/// Custom iOS-style toggle styled with the brand peach for the "on" state.
struct PeachToggle: View {
    @Binding var isOn: Bool

    private let width: CGFloat = 44
    private let height: CGFloat = 26
    private let knob: CGFloat = 22

    var body: some View {
        ZStack {
            Capsule()
                .fill(isOn ? AppColors.peachPrimary : AppColors.toggleOffTrack)
                .frame(width: width, height: height)
            Circle()
                .fill(Color.white)
                .frame(width: knob, height: knob)
                .shadow(color: Color.black.opacity(0.12), radius: 2, y: 1)
                .offset(x: isOn ? (width - knob) / 2 - 2 : -(width - knob) / 2 + 2)
        }
        .animation(.easeOut(duration: 0.18), value: isOn)
        .onTapGesture { isOn.toggle() }
    }
}
