// Camera/ContentViewWrapper.swift (FIXED: Back Button Placement using safeAreaInset)

import SwiftUI

struct ContentViewWrapper: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Layer 1: Your camera view, ignoring safe area to fill the whole screen
            ContentView()
                .ignoresSafeArea() // This needs to be on the ContentView or its container

            // Layer 2: Overlay for the custom back button.
            // Use safeAreaInset to properly place the button below the status bar.
            Color.clear // A clear background so the ZStack knows its bounds
        }
        // Place the button using safeAreaInset, which creates space BELOW the status bar
        .safeAreaInset(edge: .top, alignment: .leading) { // Add an inset at the top, aligned leading
            Button {
                dismiss() // This action will dismiss the fullScreenCover
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.backward") // Standard back chevron icon
                        .font(.system(size: 17, weight: .semibold)) // Mimic system back chevron size/weight

                    Text("Back") // Text label "Back"
                        .font(.body) // Standard body font size for the text
                }
                .foregroundColor(.blue) // Standard iOS navigation back button color
                // No background here, as system navigation buttons usually don't have one
                // You can add it back (e.g., .background(Color.black.opacity(0.5)).cornerRadius(10))
                // if you prefer the previous button's visual style, but this is more "native"
            }
            .padding(.leading, 16) // Padding from the left edge of the safe area
            .padding(.vertical, 8) // Optional: Add vertical padding for larger tap area if no background
            // No .padding(.top) needed here, as safeAreaInset handles it
            // No .ignoresSafeArea needed on the button.
        }
    }
}

struct ContentViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewWrapper()
    }
}
