// Features/Home/HomeScreen.swift

import SwiftUI
import PhotosUI
import SwiftData

struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var analyzer = ImageAnalyzer()
    
    @Query(sort: \LabeledItem.timestamp, order: .reverse) private var recentItems: [LabeledItem]
    
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var analysisResult: AnalysisResult?
    @State private var showSettingsSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    ColorTipView(tip: viewModel.dailyTip)
                    
                    QuickActionsView(actions: viewModel.quickActions) {
                        showPhotoPicker = true
                    }
                    
                    if !recentItems.isEmpty {
                        RecentsView(items: Array(recentItems.prefix(5)))
                    }
                    
                    ChatPreviewView()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettingsSheet = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showSettingsSheet) { SettingsView() }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newValue in
            guard let newValue = newValue else { return }
            Task {
                if let image = await loadImage(from: newValue) {
                    self.analysisResult = await analyzer.analyze(image: image)
                }
            }
        }
    }

    private func loadImage(from item: PhotosPickerItem) async -> UIImage? {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return nil }
        return UIImage(data: data)
    }
}

// MARK: – Subviews

struct ColorTipView: View {
    let tip: ColorTip
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 44, height: 44)
                    .shadow(color: .yellow.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Color Tip")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)

                Text(tip.text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(colorScheme == .dark ?
                   Color(.systemGray6) :
                   Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.15 : 0.05),
                radius: 8, x: 0, y: 4)
    }
}

// --- ENHANCED QuickActionsView ---
struct QuickActionsView: View {
    let actions: [QuickAction]
    let onAnalyzeTapped: () -> Void
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(actions) { action in
                    // The 'Analyze' action is a Button
                    if action.title == "Analyze" {
                        Button(action: onAnalyzeTapped) {
                            QuickActionButton(action: action)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // All other actions are NavigationLinks
                        NavigationLink(destination: destinationView(for: action)) {
                            QuickActionButton(action: action)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    // Helper to keep navigation logic clean
    @ViewBuilder
    private func destinationView(for action: QuickAction) -> some View {
        switch action.title {
        case "Camera": ContentView()
        case "Compare": ColorComparisonView()
        case "Sort": SortingAssistantView()
        default: Text("\(action.title) View (Placeholder)")
        }
    }
}

// --- ENHANCED QuickActionButton ---
struct QuickActionButton: View {
    let action: QuickAction
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 11) {
            // Icon with enhanced styling
            ZStack {
                Circle()
                    .fill(action.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: action.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(action.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(action.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80) // Fixed height for consistency
        .background(backgroundColor) // Removed gradient, using solid color
        .cornerRadius(16)
        .contentShape(Rectangle())
        .shadow(
            color: shadowColor,
            radius: 8,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Computed Properties for Dark Mode Support
    
    private var backgroundColor: Color {
        if colorScheme == .dark {
            return Color(.systemGray6)
        } else {
            return Color.white
        }
    }
    
    private var borderColor: Color {
        if colorScheme == .dark {
            return Color.white.opacity(0.12)
        } else {
            return Color.gray.opacity(0.18)
        }
    }
    
    private var shadowColor: Color {
        if colorScheme == .dark {
            return Color.black.opacity(0.25)
        } else {
            return Color.black.opacity(0.08)
        }
    }
    
    private var iconBackgroundColor: Color {
        if colorScheme == .dark {
            return action.color.opacity(0.25)
        } else {
            return action.color.opacity(0.12)
        }
    }
    
    private var primaryTextColor: Color {
        if colorScheme == .dark {
            return Color.white
        } else {
            return Color.black
        }
    }
    
    private var secondaryTextColor: Color {
        if colorScheme == .dark {
            return Color.white.opacity(0.8)
        } else {
            return Color.gray
        }
    }
}

// --- ENHANCED RecentsView ---
struct RecentsView: View {
    let items: [LabeledItem]
    @Environment(\.colorScheme) var colorScheme
    
    @State private var selectedItem: LabeledItem? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recently Labeled")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                NavigationLink(destination: SavedItemsView()) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.secondary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(items) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            RecentItemCard(item: item)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 4) // Add slight padding for shadows
            }
        }
        .sheet(item: $selectedItem) { item in
            RecentItemDetailView(item: item)
        }
    }
}

struct RecentItemCard: View {
    let item: LabeledItem
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let cardWidth = (UIScreen.main.bounds.width - 48) / 2
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                // Background Image
                Image(uiImage: fixImageOrientation(UIImage(data: item.imageData) ?? UIImage()))
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: cardWidth * 1.2)
                    .clipped()

                // Gradient Overlay
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .black.opacity(0.3),
                                .black.opacity(0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)

                // Text Content
                VStack(alignment: .leading, spacing: 6) {
                    Spacer()

                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        Circle()
                            .fill(colorFromString(item.identifiedColor))
                            .frame(width: 16, height: 16)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )

                        Text(item.identifiedColor)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.4))
                            )
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: cardWidth, height: cardWidth * 1.2)
            .clipped()
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        .frame(width: cardWidth)
    }
    
    // Helper function to fix image orientation
    private func fixImageOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? image
    }
}

struct RecentItemDetailView: View {
    let item: LabeledItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Image(uiImage: UIImage(data: item.imageData) ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.name)
                            .font(.title2)
                            .fontWeight(.semibold)

                        HStack(spacing: 8) {
                            Circle()
                                .fill(colorFromString(item.identifiedColor))
                                .frame(width: 18, height: 18)
                            Text(item.identifiedColor)
                                .font(.body)
                                .fontWeight(.medium)
                        }

                        Text("Labeled: \(item.timestamp.formatted(date: .abbreviated, time: .shortened))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Details")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct ChatPreviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chat with Chroma")
                .font(.title2)
                .fontWeight(.bold)
            
            NavigationLink(destination: ChatView()) {
                HStack {
                    Text("Ask about a color, a match, or anything...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Shared Helpers
func colorFromString(_ colorString: String) -> Color {
    switch colorString.lowercased() {
    case "red": return .red
    case "blue": return .blue
    case "green": return .green
    case "yellow": return .yellow
    case "orange": return .orange
    case "purple": return .purple
    case "pink": return .pink
    case "brown": return .brown
    case "gray", "grey": return .gray
    case "black": return .black
    case "white": return .white
    default: return .gray
    }
}
