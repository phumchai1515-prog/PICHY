//
//  AvatarPicker.swift
//  PICHY
//
//  Tappable avatar that lets the user pick a profile photo. Picked images are
//  downscaled and JPEG-compressed before being stored.
//

import SwiftUI
import PhotosUI

struct AvatarPicker: View {
    let profile: UserProfile
    var size: CGFloat = 96
    /// Called with new JPEG data when a photo is picked.
    let onPick: (Data) -> Void

    @State private var selection: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selection, matching: .images, photoLibrary: .shared()) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(profile: profile, size: size, cornerRadius: size * 0.32)
                    .heroShadow()

                Image(systemName: "camera.fill")
                    .font(.system(size: size * 0.16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: size * 0.34, height: size * 0.34)
                    .background(Circle().fill(AppColors.peachPrimary))
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .offset(x: 4, y: 4)
            }
        }
        .buttonStyle(.plain)
        .onChange(of: selection) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let downscaled = ImageProcessing.downscaledJPEG(from: data) {
                    onPick(downscaled)
                }
            }
        }
    }
}
