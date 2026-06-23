//
//  PINPadView.swift
//  PICHY
//
//  Reusable PIN entry: title, filled dots, numeric keypad, optional biometric
//  button. `onComplete` returns true to accept, false to shake-and-clear.
//

import SwiftUI

struct PINPadView: View {
    let title: String
    let subtitle: String
    var length: Int = 6
    var biometric: BiometricKind = .none
    var onBiometric: (() -> Void)? = nil
    /// Return true to accept the code, false to reject (shake + clear).
    let onComplete: (String) -> Bool

    @State private var code: String = ""
    @State private var shake: Bool = false

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text(title)
                    .font(AppFont.display(22, .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text(subtitle)
                    .font(AppFont.body(13, .regular))
                    .foregroundColor(AppColors.textMuted)
                    .multilineTextAlignment(.center)
            }

            dots
                .offset(x: shake ? -10 : 0)
                .animation(.default, value: shake)

            keypad
        }
        .padding(.horizontal, 32)
    }

    private var dots: some View {
        HStack(spacing: 18) {
            ForEach(0..<length, id: \.self) { i in
                Circle()
                    .fill(i < code.count ? AppColors.peachPrimary : AppColors.toggleOffTrack)
                    .frame(width: 14, height: 14)
            }
        }
    }

    private var keypad: some View {
        VStack(spacing: 18) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 28) {
                    ForEach(1...3, id: \.self) { col in
                        digitButton(row * 3 + col)
                    }
                }
            }
            HStack(spacing: 28) {
                bottomLeftButton
                digitButton(0)
                backspaceButton
            }
        }
    }

    private func digitButton(_ n: Int) -> some View {
        Button {
            append("\(n)")
        } label: {
            Text("\(n)")
                .font(AppFont.display(26, .regular))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 72, height: 72)
                .background(Circle().fill(Color.white))
                .cardShadow()
        }
        .buttonStyle(.pressableScale)
    }

    @ViewBuilder
    private var bottomLeftButton: some View {
        if biometric != .none, let onBiometric {
            Button(action: onBiometric) {
                Image(systemName: biometric.iconName)
                    .font(.system(size: 26))
                    .foregroundColor(AppColors.peachPrimary)
                    .frame(width: 72, height: 72)
            }
            .buttonStyle(.pressableScale)
        } else {
            Color.clear.frame(width: 72, height: 72)
        }
    }

    private var backspaceButton: some View {
        Button {
            if !code.isEmpty { code.removeLast() }
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 24))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 72, height: 72)
        }
        .buttonStyle(.pressableScale)
    }

    private func append(_ digit: String) {
        guard code.count < length else { return }
        code += digit
        guard code.count == length else { return }
        let entered = code
        if onComplete(entered) {
            code = ""
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            shake.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                code = ""
                shake = false
            }
        }
    }
}
