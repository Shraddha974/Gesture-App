//
//  RoboHeroView.swift
//  GestureApp
//
//  Created by Shraddha on 24/12/25.
//

import SwiftUI

struct RoboHeroView: View {

    @State private var float = false

    var body: some View {
        ZStack {

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.trelleborgGold.opacity(0.35),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 200
                    )
                )
                .frame(width: 320, height: 320)

            VStack(spacing: 0) {

                // Head
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.trelleborgBlack)
                        .frame(width: 130, height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.trelleborgGold.opacity(0.4), lineWidth: 2)
                        )

                    // Face
                    VStack(spacing: 12) {
                        HStack(spacing: 14) {

                            // 👁 Eyes — gold
                            Circle()
                                .fill(Color.trelleborgGold)
                                .frame(width: 12, height: 12)

                            Circle()
                                .fill(Color.trelleborgGold)
                                .frame(width: 12, height: 12)
                        }

                        // 👄 Mouth — gold capsule
                        Capsule()
                            .fill(Color.trelleborgGold)
                            .frame(width: 36, height: 10)
                    }
                }

                // Body
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.trelleborgGraphite,
                                Color.black
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 150, height: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.trelleborgGold.opacity(0.3), lineWidth: 1)
                    )
            }
            .offset(y: float ? -10 : 10)
            .animation(
                .easeInOut(duration: 2).repeatForever(autoreverses: true),
                value: float
            )
            .onAppear { float = true }
        }
    }
}

struct RoboHeroHeader: View {

    var body: some View {
        VStack(spacing: 14) {

            Text("Meet ✨ GestureAI")
                .font(.largeTitle.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [.trelleborgGold, .trelleborgBlack],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Your Daily AI Vibe Agent")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}



