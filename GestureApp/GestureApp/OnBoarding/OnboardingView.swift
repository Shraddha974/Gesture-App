//
//  onBoardingView.swift
//  GestureApp
//
//  Created by Shraddha on 19/12/25.
//

import SwiftUI
import Foundation

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var showingWelcome = true
    
    private let totalPages = 5
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            if showingWelcome {
                welcomeScreen
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                onboardingCarousel
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingWelcome)
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }
    
    private var welcomeScreen: some View {
        VStack(spacing: 40) {

            Spacer(minLength: 40)

            RoboHeroView()

            RoboHeroHeader()
                .padding(.horizontal, 40)

            Text("Voice • Gestures • Intelligence\nAll in one assistant")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button(action: {
                withAnimation {
                    showingWelcome = false
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.trelleborgGold, .trelleborgGraphite],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(radius: 10)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.15),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    
    private var onboardingCarousel: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: index == currentPage ? 32 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 40)
            
            // Content
            TabView(selection: $currentPage) {
                chatModesPage.tag(0)
                voiceFeaturesPage.tag(1)
                documentUploadPage.tag(2)
                webSearchPage.tag(3)
                settingsPage.tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
            
            // Navigation buttons
            HStack(spacing: 20) {
                if currentPage > 0 {
                    Button(action: {
                        withAnimation {
                            currentPage -= 1
                        }
                    }) {
                        Text("Previous")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(width: 100, height: 50)
                            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12.0))
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient(
                                        colors: [.trelleborgGold, .trelleborgGraphite],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                            )
                    }
                } else {
                    Spacer()
                        .frame(width: 100)
                }
                
                Spacer()
                
                Button(action: {
                    if currentPage < totalPages - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(currentPage < totalPages - 1 ? "Next" : "Done")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(width: 100, height: 50)
                        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12.0))
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    colors: [.trelleborgGold, .trelleborgGraphite],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
    
    private var chatModesPage: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .glassEffect(.regular)
                
                Text("Three Modes")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Choose the perfect mode for your needs")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "message.fill",
                    title: "Voice Recognition",
                    description: "Direct AI conversations without additional context",
                    color: .blue
                )
                
                FeatureRow(
                    icon: "doc.text.fill",
                    title: "Gesture AI",
                    description: "Different hand gestures for different functionality",
                    color: .green
                )
                
                FeatureRow(
                    icon: "text.badge.checkmark",
                    title: "Smart Autofill feature",
                    description: "AI powered form filling",
                    color: .orange
                )
                
                FeatureRow(
                    icon: "camera.viewfinder",
                    title: "Magic Mirror",
                    description: "AR photo real time experience",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var voiceFeaturesPage: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                    .glassEffect(.regular)
                
                Text("Voice Interaction")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Hands-free conversations with your AI assistant")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "mic.fill",
                    title: "Speech-to-Text",
                    description: "Speak your messages instead of typing",
                    color: .purple
                )
                
                FeatureRow(
                    icon: "speaker.wave.2.fill",
                    title: "Text-to-Speech",
                    description: "Listen to AI responses with natural voice synthesis",
                    color: .indigo
                )
                
                FeatureRow(
                    icon: "phone.circle.fill",
                    title: "Live Voice Mode",
                    description: "Continuous voice conversations like talking to a person",
                    color: .pink
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var documentUploadPage: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "doc.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .glassEffect(.regular)
                
                Text("Gesture Processing")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Experience different functionality using hand gesture")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "doc.fill",
                    title: "Hand Gesture",
                    description: "Wave your hand to navigate between view and accessing functionality",
                    color: .red
                )
                
                FeatureRow(
                    icon: "magnifyingglass.circle.fill",
                    title: "Semantic Search",
                    description: "Find relevant information using AI-powered vector search",
                    color: .teal
                )
                
                FeatureRow(
                    icon: "brain.head.profile",
                    title: "RAG Technology",
                    description: "Each chat session maintains its own document context",
                    color: .green
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var webSearchPage: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "text.badge.checkmark")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .glassEffect(.regular)
                
                Text("Smart Autofill Integration")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("AI powered form filling")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "safari.fill",
                    title: "Real-time Scan",
                    description: "Search the web for current information and news",
                    color: .blue
                )
                
                FeatureRow(
                    icon: "link.circle.fill",
                    title: "Source Citations",
                    description: "View and access the sources used in AI responses",
                    color: .cyan
                )
                
                FeatureRow(
                    icon: "rectangle.and.text.magnifyingglass",
                    title: "Content Analysis",
                    description: "AI analyzes web content to provide accurate summaries",
                    color: .orange
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var settingsPage: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                    .glassEffect(.regular)
                
                Text("Magic Mirror")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Personalize your AR photo experience")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "paintbrush.fill",
                    title: "Theme Options",
                    description: "Choose between light, dark, or system appearance",
                    color: .purple
                )
                
                FeatureRow(
                    icon: "person.2.fill",
                    title: "Community Access",
                    description: "Join our GitHub and Discord communities",
                    color: .blue
                )
                
                FeatureRow(
                    icon: "checkmark.circle.fill",
                    title: "Ready to Start",
                    description: "You're all set to begin using Aeru!",
                    color: .green
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
        dismiss()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .clipShape(Circle())
                .glassEffect(.regular)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12.0))
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

#Preview {
    OnboardingView()
}
