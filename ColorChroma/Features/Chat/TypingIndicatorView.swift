// TypingIndicatorView.swift

import SwiftUI

struct TypingIndicatorView: View {
    @State private var isAnimating = false
    private let dotCount = 3
    private let dotSize: CGFloat = 8
    private let dotDelay: Double = 0.2 // Delay between each dot's animation
    private let animationDuration: Double = 0.5

    var body: some View {
        HStack { // Aligns the bubble to the left
            HStack(spacing: 6) {
                ForEach(0..<dotCount, id: \.self) { index in
                    Circle()
                        .frame(width: dotSize, height: dotSize)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(
                            Animation.easeInOut(duration: animationDuration)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * dotDelay),
                            value: isAnimating
                        )
                }
            }
            .padding(12)
            .background(Color(.systemGray5))
            .cornerRadius(16)
            
            Spacer() // Pushes the bubble to the left
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct TypingIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        TypingIndicatorView()
            .padding()
    }
}
