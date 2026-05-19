//
//  GestureAppApp.swift
//  GestureApp
//
//  Created by Shraddha on 19/12/25.
//

import SwiftUI

@main
struct GestureAppApp: App {
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @StateObject private var session = AppSession()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MagicMirrorScreenView()
                    .environmentObject(session)
//               if showOnboarding {
//                    OnboardingView()
//                        .transition(.opacity)
//                        .zIndex(1)
//                }
            }
            //.animation(.easeInOut(duration: 0.3), value: showOnboarding)
//            .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
//                withAnimation {
//                    showOnboarding = false
//                }
//            }
        }
    }
}

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}
