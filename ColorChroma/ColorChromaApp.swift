// AppEntry/ColorblindHelperApp.swift (With Smooth Onboarding Transition)

import SwiftUI
import SwiftData

@main
struct ColorblindHelperApp: App {
    @AppStorage("appColorScheme") private var selectedColorScheme: AppColorScheme = .system
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @State private var isShowingOnboarding: Bool = true
    
    init() {
        _isShowingOnboarding = State(initialValue: !hasCompletedOnboarding)
        // Optional debugging override:
        // _isShowingOnboarding = State(initialValue: true)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isShowingOnboarding {
                    // --- FIX: No NavigationStack here anymore ---
                    OnboardingView {
                        hasCompletedOnboarding = true
                        withAnimation {
                            isShowingOnboarding = false
                        }
                    }
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                } else {
                    MainTabView()
                        .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                }
            }
            .onAppear {
                if hasCompletedOnboarding {
                    isShowingOnboarding = false
                }
            }
            .preferredColorScheme(mapColorScheme())
            .modelContainer(for: LabeledItem.self)
        }
    }
    
    private func mapColorScheme() -> ColorScheme? {
        switch selectedColorScheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}
