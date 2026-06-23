//
//  MascotView.swift
//  PICHY
//
//  The brand mascot "น้องพีช" (Nong Peach) — a chibi nurse. Backed by the
//  vector assets in Assets.xcassets so it stays crisp at any size. Single
//  source of truth for showing the mascot across onboarding, the lock screen,
//  and empty states.
//

import SwiftUI

struct MascotView: View {
    enum Pose {
        case full   // standing, waving — hero moments (welcome, empty states)
        case head   // head only — compact brand mark (lock screen, badges)

        var assetName: String {
            switch self {
            case .full: return "MascotFull"
            case .head: return "MascotHead"
            }
        }
    }

    var pose: Pose = .full
    var size: CGFloat = 120

    var body: some View {
        Image(pose.assetName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityLabel("น้องพีช มาสคอตของ PICHY")
    }
}

/// The mascot head framed in the soft peach ring used for brand avatars
/// (welcome badge, lock screen). Matches the logo handoff: gradient ring +
/// white border.
struct MascotBadge: View {
    var size: CGFloat = 96
    private var ringPadding: CGFloat { size * 0.1 }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xFFE9D8), Color(hex: 0xFFD3B8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .heroShadow()
            MascotView(pose: .head, size: size - ringPadding * 2)
                .offset(y: size * 0.06) // sink the chin toward the ring base
                .clipShape(Circle())
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 32) {
        MascotView(pose: .full, size: 200)
        MascotBadge(size: 110)
    }
    .padding()
    .background(AppColors.bgScreen)
}
