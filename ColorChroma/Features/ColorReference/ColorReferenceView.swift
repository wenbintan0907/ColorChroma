// Features/ColorReference/ColorReferenceView.swift (Updated to use sectioned data)

import SwiftUI

struct ColorReferenceView: View {
    // The full library of colors, now sourced from the sectioned data
    private let allSections = StandardColorProvider.sections
    
    @State private var searchText = ""
    
    // A computed property to filter sections and their colors based on search text
    private var filteredSections: [ColorSection] {
        if searchText.isEmpty {
            return allSections
        } else {
            // Otherwise, filter the sections and their contents
            return allSections.compactMap { section -> ColorSection? in
                // Find colors within this section that match the search text
                let matchingColors = section.colors.filter {
                    $0.name.localizedCaseInsensitiveContains(searchText)
                }
                // Only return the section if it contains at least one matching color
                return matchingColors.isEmpty ? nil : ColorSection(name: section.name, colors: matchingColors)
            }
        }
    }
    
    var body: some View {
        // The List now iterates over the filteredSections to create a sectioned layout
        List {
            ForEach(filteredSections) { section in
                // Create a Section view for each ColorSection
                Section(header: Text(section.name).font(.headline)) {
                    // Then, iterate over the colors within that section
                    ForEach(section.colors) { color in
                        NavigationLink(destination: ColorDetailView(standardColor: color)) {
                            ColorRow(standardColor: color)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Color Reference")
        .searchable(text: $searchText, prompt: "Search for a color")
    }
}

// MARK: - Subviews (These remain unchanged)

private struct ColorRow: View {
    let standardColor: StandardColor
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(standardColor.swiftUIColor)
                .frame(width: 30, height: 30)
                .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
            
            Text(standardColor.name)
                .font(.headline)
        }
        .padding(.vertical, 8)
    }
}

struct ColorDetailView: View {
    let standardColor: StandardColor
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(standardColor.swiftUIColor)
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 12) {
                Text(standardColor.name)
                    .font(.largeTitle.weight(.bold))
                
                Text(standardColor.hexCode)
                    .font(.title3.monospaced())
                    .foregroundColor(.secondary)
            }
            .padding(40)
            
            Spacer()
        }
        .navigationTitle(standardColor.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Preview
struct ColorReferenceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ColorReferenceView()
        }
    }
}
