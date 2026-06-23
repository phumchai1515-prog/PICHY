//
//  AppRootView.swift
//  PICHY
//
//  Top-level coordinator: decides between onboarding, the lock screen, and the
//  main app, and re-locks when the app is backgrounded.
//

import SwiftUI

struct AppRootView: View {
    @StateObject private var store = AppStore()
    @StateObject private var auth = AuthManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if !store.hasOnboarded || auth.state == .needsSetup {
                OnboardingFlow()
            } else if auth.state == .locked {
                LockScreenView()
            } else {
                RootView()
            }
        }
        .environmentObject(store)
        .environmentObject(auth)
        .animation(.easeInOut, value: auth.state)
        .animation(.easeInOut, value: store.hasOnboarded)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { auth.lock() }
        }
    }
}
