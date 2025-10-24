// Shared/CustomBackButton.swift

import SwiftUI

struct CustomBackButton: View {
    // This allows the button to dismiss the current view
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Button(action: {
            dismiss()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Back")
                    .font(.body)
            }
        }
        // By not setting a foreground color here, it will automatically
        // inherit the app's global tint color (which you set to .blue)
        // or a default color provided by the navigation bar.
    }
}

struct CustomBackButton_Previews: PreviewProvider {
    static var previews: some View {
        // You can wrap it in a toolbar for a more accurate preview
        NavigationView {
            VStack {
                Text("Content goes here")
            }
            .navigationTitle("Preview")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CustomBackButton()
                }
            }
        }
    }
}
