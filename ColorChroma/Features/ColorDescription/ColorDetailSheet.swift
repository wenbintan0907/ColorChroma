import SwiftUI

// MARK: — Parent View

struct ParentView: View {
    @State private var showDetail = false

    var body: some View {
        Button("Show Color Detail") {
            showDetail.toggle()
        }
        .sheet(isPresented: $showDetail) {
            ColorDetailSheet(
                color: UIColor(red: 0.251, green: 0.310, blue: 0.357, alpha: 1.0),
                colorName: "Dark Dull Blue",
                description: """
                This deep shade possesses a quiet dignity, reminiscent of twilight settling over a shadowy forest or the velvety petals of a midnight bloom. It carries the weight of evening hours and whispered secrets, evoking feelings of contemplation and serene melancholy.
                """,
                isLoading: false
            )
            // Snap to medium, large, or full‑screen (1.0)
            .presentationDetents([.medium, .large, .fraction(1.0)])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: — Detail Sheet

struct ColorDetailSheet: View {
    let color: UIColor
    let colorName: String
    let description: String?
    let isLoading: Bool

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            // Full‑bleed background
            Color(.systemBackground)
                .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 0) {
                // Drag grabber
                Capsule()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.vertical, 8)

                // Scrollable content
                ScrollView {
                    VStack(spacing: 24) {
                        ColorSwatchView(color: color)

                        // Name + Hex
                        VStack(spacing: 6) {
                            Text(colorName)
                                .font(.title.bold())
                                .multilineTextAlignment(.center)

                            Text(color.toHex() ?? "#------")
                                .font(.callout.monospaced())
                                .foregroundColor(.secondary)
                        }

                        // Description
                        DescriptionCard(description: description, isLoading: isLoading)

                        // Done button
                        Button("Done") {
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.top, 8)
                    }
                    .padding(20)
                }
            }
        }
        .cornerRadius(24, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: -10)
        .preferredColorScheme(.dark)
    }
}

// MARK: — Subviews

private struct ColorSwatchView: View {
    let color: UIColor

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(uiColor: color))
            .frame(height: 180)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color(uiColor: color).opacity(0.35), radius: 10, x: 0, y: 5)
    }
}

private struct DescriptionCard: View {
    let description: String?
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.subheadline.weight(.medium))
                    // Using .blue is fine here, as the material background
                    // provides a nice contrast in both modes.
                    .foregroundColor(.blue)
                
                Text("Description")
                    .font(.headline.weight(.semibold))
                    // The .primary color will be black/white automatically
            }

            Group {
                if isLoading {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("Generating description…")
                            .foregroundColor(.secondary)
                    }
                } else if let description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.primary) // Adapts automatically
                        .lineSpacing(4)
                } else {
                    Text("Could not generate a description.")
                        .foregroundColor(.secondary) // Adapts automatically
                }
            }
        }
        .padding()
        // 1. Use a material background. It provides a frosted-glass
        // effect that adapts beautifully to any wallpaper or background.
        .background(.regularMaterial)
        .cornerRadius(16)
        // 2. Add a subtle stroke for better edge definition, especially in dark mode.
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: — Corner‑Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            ).cgPath
        )
    }
}

// MARK: — Previews

struct ParentView_Previews: PreviewProvider {
    static var previews: some View {
        ParentView()
    }
}
