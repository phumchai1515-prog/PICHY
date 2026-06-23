//
//  EditProfileView.swift
//  PICHY
//
//  Edit name, role, hospital, and profile photo.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var role: String
    @State private var hospital: String
    @State private var avatarData: Data?

    init(profile: UserProfile) {
        _name = State(initialValue: profile.name)
        _role = State(initialValue: profile.role)
        _hospital = State(initialValue: profile.hospital)
        _avatarData = State(initialValue: profile.avatarData)
    }

    private var draft: UserProfile {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return UserProfile(
            name: trimmed,
            role: role,
            hospital: hospital,
            initial: trimmed.first.map(String.init) ?? store.profile.initial,
            avatarData: avatarData
        )
    }

    var body: some View {
        ZStack {
            AppColors.bgScreen.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    AvatarPicker(profile: draft, size: 104) { avatarData = $0 }
                        .padding(.top, 12)

                    VStack(spacing: 12) {
                        LabeledTextField(title: "ชื่อ", text: $name, placeholder: "ชื่อของคุณ")
                        LabeledTextField(title: "ตำแหน่ง", text: $role, placeholder: "พยาบาลวิชาชีพ")
                        LabeledTextField(title: "โรงพยาบาล", text: $hospital, placeholder: "รพ.")
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }

            VStack {
                Spacer()
                GradientButton(title: "บันทึก") { save() }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
        }
        .navigationTitle("แก้ไขโปรไฟล์")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save() {
        store.updateProfile(draft)
        dismiss()
    }
}
