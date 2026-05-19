//
//  VoiceButton.swift
//  GestureApp
//
//  Created by Shraddha on 22/12/25.
//

import SwiftUI


struct VoiceButton: View {

    let listening: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(listening ? Color.trelleborgGold : Color.gray.opacity(0.2))
                    .frame(width: 70, height: 70)
                    .shadow(radius: 10)

                Image(systemName: "mic.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            }
            .scaleEffect(listening ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                       value: listening)
        }
    }
}
