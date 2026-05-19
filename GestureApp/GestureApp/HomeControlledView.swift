//
//  GestureControlledView.swift
//  GestureApp
//
//  Created by Shraddha on 05/01/26.
//

import SwiftUI

struct HomeControlledView: View {
    
    @State private var route: Route?
    @EnvironmentObject var session: AppSession
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // Background
                LinearGradient(
                    colors: [
                        Color.white,
                        Color.trelleborgGraphite
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 100) {
                    Spacer()
                    HomeHeroHeader()
                    
                    VStack(spacing: 16) {
                        
                        FeatureCard(
                            icon: "mic.fill",
                            title: "Voice AI",
                            subtitle: "Talk & auto-fill forms"
                        ) {
                            route = .voiceForm
                        }
                        
                        FeatureCard(
                            icon: "hand.wave.fill",
                            title: "Gesture AI",
                            subtitle: "Hands-free interactions"
                        ) {
                            route = .gestureFeature
                        }
                        
                        FeatureCard(
                            icon: "text.badge.checkmark",
                            title: "Smart Autofill",
                            subtitle: "AI-powered form filling"
                        ) {
                            route = .autofillFormFeature
                        }
                        
                        FeatureCard(
                            icon: "camera.viewfinder",
                            title: "Magic Mirror",
                            subtitle: "AR photo experience"
                        ) {
                            route = .magicMirror
                        }
                        
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationDestination(item: $route) { route in
                switch route {
                case .voiceForm:
                    VoiceFormView()
                case .gestureFeature:
                    ImageSearchView()
                case .autofillFormFeature:
                    AutoFillFormView()
                case .magicMirror:
                    MagicMirrorScreenView()
                }
            }
        }
    }
}



struct FeatureCard: View {
    
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                
                ZStack {
                    Circle()
                        .fill(Color.trelleborgGold.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.trelleborgGold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.black.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.trelleborgGold.opacity(0.25), lineWidth: 1)
                    )
            )
        }
    }
}


struct HomeHeroHeader: View {
    
    var body: some View {
        VStack(spacing: 10) {
            
            Text("GestureAI")
                .font(.largeTitle.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [.trelleborgGold, .black],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Rejoice 2025 • AI Experience Hub")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 30)
    }
}
