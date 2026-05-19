//
//  HandCursorOverlay.swift
//  GestureApp
//
//  Created by Shraddha on 24/12/25.
//

import SwiftUI

struct HandCursorOverlay: View {
    
    @ObservedObject var hand: HandGestureManager
    
    var body: some View {
        ZStack {
            if let p = hand.pinchPoint {
                Circle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 20, height: 20)
                    .position(p)
            }
        }
        .ignoresSafeArea()
    }
}

struct ActionButton: View {
    
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding()
                .background(Color.trelleborgGold)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}



enum Route: Hashable {
    case voiceForm
    case gestureFeature
    case autofillFormFeature
    case magicMirror
}
