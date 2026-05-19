//
//  PremiumCommentBox.swift
//  GestureApp
//
//  Created by Shraddha on 22/12/25.
//

import SwiftUI

struct PremiumCommentBox: View {

    @Binding var text: String
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Comment")
                .font(.headline)

            ZStack(alignment: .topLeading) {

                TextEditor(text: $text)
                    .focused($focused)
                    .padding()
                    .frame(height: 140)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: focused ? .blue.opacity(0.25) : .black.opacity(0.1),
                                    radius: 12, y: 6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(focused ? Color.blue : Color.clear, lineWidth: 1.5)
                    )

                if text.isEmpty {
                    Text("Speak or type your comment…")
                        .foregroundColor(.gray)
                        .padding(.top, 18)
                        .padding(.leading, 16)
                }
            }
        }
    }
}
