// Features/InfoHub/InfoHubView.swift (With redesigned InfoCard)

import SwiftUI

struct InfoHubView: View {
    @StateObject private var viewModel = InfoHubViewModel()
    
    @AppStorage("colorblindnessType") private var userColorblindnessType: ColorblindnessType = .normal
    
    @State private var selectedType: ColorblindnessType = .normal
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Scrollable Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ColorblindnessType.allCases) { type in
                            Button {
                                selectedType = type
                            } label: {
                                Text(type.shortName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedType == type ? Color.accentColor : Color(.systemGray5))
                                    .foregroundColor(selectedType == type ? .white : .primary)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Dynamically display content for the selected type
                if let info = viewModel.infoData[selectedType] {
                    VStack(spacing: 16) {
                        InfoCard(title: "Description", content: info.description, icon: "text.alignleft", color: .blue)
                        InfoCard(title: "Impact on Daily Life", content: info.impact, icon: "figure.walk", color: .orange)
                        InfoCard(title: "Prevalence", content: info.prevalence, icon: "figure.2.right.holdinghands", color: .green)
                        InfoCard(title: "Symptoms", content: info.symptoms, icon: "heart.text.square.fill", color: .red)
                        InfoCard(title: "Problematic Color Combinations", content: info.problematicColorCombinations, icon: "eye.trianglebadge.exclamationmark.fill", color: .purple)
                    }
                    .padding(.horizontal)
                } else {
                    Text("No information available for this type.")
                        .padding()
                }
            }
            .padding(.top)
            .padding(.bottom)
        }
        .navigationTitle("Colorblindness Info")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            self.selectedType = self.userColorblindnessType
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedType)
    }
}

// --- THIS IS THE REDESIGNED InfoCard STRUCT ---
struct InfoCard: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        // Main container using an HStack
        HStack(alignment: .top, spacing: 16) {
            
            // Left side: Icon with solid background
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white) // White icon for max contrast
                .frame(width: 44, height: 44)
                .background(color) // Use the passed-in color for the background
                .clipShape(Circle())
            
            // Right side: Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary) // Subtle gray for the title
                
                Text(.init(content)) // Use .init() to render markdown
                    .font(.body)
                    .foregroundColor(.primary) // Main text is primary color
                    .lineSpacing(4)
            }
        }
        .padding() // Inner padding for content
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial) // Modern iOS blur effect
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct InfoHubView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InfoHubView()
        }
    }
}
