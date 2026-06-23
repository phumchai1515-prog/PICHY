//
//  AvatarView.swift
//  PICHY
//
//  Shows the user's profile photo if set, otherwise their initial on the
//  brand gradient. Single source of truth for how avatars render app-wide.
//

import SwiftUI

struct AvatarView: View {
    let profile: UserProfile
    var size: CGFloat = 80
    var cornerRadius: CGFloat = 28

    private var image: UIImage? {
        guard let data = profile.avatarData else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                AppColors.peachGradient
                Text(profile.initial)
                    .font(AppFont.display(size * 0.42, .bold))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
