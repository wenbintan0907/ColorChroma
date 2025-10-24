// Features/Onboarding/OnboardingView.swift (Simplistic Redesign)

import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    
    @State private var currentPageIndex = 0
    private let pages = OnboardingData.pages
    
    var body: some View {
        VStack(spacing: 0) { // Main vertical stack, spacing controlled by children
            // The TabView for swipeable pages
            TabView(selection: $currentPageIndex) {
                ForEach(pages.indices, id: \.self) { index in
                    OnboardingPageView(page: pages[index]) // Page content
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Hide default dots
            
            // Custom page indicator and buttons
            VStack(spacing: 20) { // Spacing between dots and buttons
                // Custom dot indicator
                HStack(spacing: 8) { // Spacing between dots
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(currentPageIndex == index ? Color.primary : Color.secondary) // Adaptive colors
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPageIndex) // Animate dot change
                    }
                }
                
                // Conditional Buttons
                if currentPageIndex == pages.count - 1 {
                    // Last page shows two options
                    VStack(spacing: 12) { // Spacing between buttons
                        NavigationLink(destination: ColorTestView(onComplete: onComplete)) {
                            ActionButton(title: "Take Perception Test", icon: "gamecontroller.fill", isPrimary: true)
                        }
                        
                        Button(action: onComplete) {
                            ActionButton(title: "Skip for Now", isPrimary: false)
                        }
                    }
                } else {
                    // "Next" button for other pages
                    Button(action: {
                        withAnimation {
                            currentPageIndex += 1
                        }
                    }) {
                        ActionButton(title: "Next", isPrimary: true)
                    }
                }
            }
            .padding(.horizontal, 24) // Horizontal padding for buttons container
            .padding(.bottom, 40) // Generous bottom padding
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Neutral background for the whole screen
    }
}

// MARK: - Reusable Components

// Reusable button style for primary/secondary actions
private struct ActionButton: View {
    let title: String
    var icon: String? = nil
    let isPrimary: Bool
    
    var body: some View {
        HStack {
            if let icon {
                Image(systemName: icon)
            }
            Text(title)
        }
        .font(.headline)
        .fontWeight(.semibold)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(isPrimary ? Color.accentColor : Color(.systemFill)) // Accent for primary, systemFill for secondary
        .foregroundColor(isPrimary ? .white : .primary) // White text on accent, adaptive on systemFill
        .clipShape(Capsule()) // Capsule shape for all buttons
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow
    }
}

// A reusable view for the content of each onboarding page
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) { // Spacing between elements on the page
            Image(systemName: page.imageName)
                .font(.system(size: 80)) // Large, simple icon
                .foregroundColor(.accentColor) // Use app's accent color
            
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary) // Adaptive text color
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary) // Adaptive secondary text color
                .multilineTextAlignment(.center)
        }
        .padding(40) // Generous padding around the content
    }
}

// No need for previews as they are covered by the main preview.
