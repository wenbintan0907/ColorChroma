// Models/OnboardingModels.swift

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingData {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "camera.viewfinder",
            title: "Instant Color ID",
            description: "Point your camera at any object to instantly identify its color name and hex code in real-time.",
            color: .red
        ),
        OnboardingPage(
            imageName: "wand.and.stars",
            title: "AI-Powered Assistants",
            description: "Use powerful AI to match clothing, analyze charts, get cooking help, and identify indicator lights.",
            color: .purple
        ),
        OnboardingPage(
            imageName: "text.bubble.fill",
            title: "Chat with Chroma",
            description: "Ask our specialized AI assistant, Chroma, any questions you have about colors and their differences.",
            color: .blue
        ),
        OnboardingPage(
            imageName: "gamecontroller.fill",
            title: "Personalize Your Experience",
            description: "Take an optional perception test to better understand your color vision. This is not a medical diagnosis.",
            color: .green
        )
    ]
}
