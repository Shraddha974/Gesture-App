//
//  PremiumField.swift
//  GestureApp
//
//  Created by Shraddha on 22/12/25.
//

import SwiftUI

struct PremiumField: View {

    let title: String
    let icon: String
    @Binding var text: String
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.caption)
                .foregroundColor(focused ? .trelleborgGold : .gray)
                .opacity(text.isEmpty ? 0 : 1)
                .animation(.easeInOut, value: text)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(.trelleborgGold)

                TextField(title, text: $text)
                    .focused($focused)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: focused ? .blue.opacity(0.25) : .black.opacity(0.08),
                            radius: 10, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(focused ? Color.blue : Color.clear, lineWidth: 1.5)
            )
        }
    }
}
