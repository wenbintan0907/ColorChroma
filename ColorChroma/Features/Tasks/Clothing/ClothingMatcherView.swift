// Features/ClothingMatcher/ClothingMatcherView.swift (Updated with fixed image heights)

import SwiftUI
import PhotosUI

struct ClothingMatcherView: View {
    @StateObject private var service = ClothingMatcherService()
    
    // State for the two photo pickers
    @State private var selectedItemA: PhotosPickerItem?
    @State private var selectedItemB: PhotosPickerItem?
    
    // State to hold the loaded images
    @State private var imageA: UIImage?
    @State private var imageB: UIImage?
    
    // State for the analysis result
    @State private var matchResult: String?
    @State private var errorMessage: String?
    @State private var isAnalyzing = false
    
    // Computed property to check if we're in results state
    private var showingResults: Bool {
        matchResult != nil || errorMessage != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Show instructions only when not displaying results
                if !showingResults && !isAnalyzing {
                    InstructionsView()
                        .padding(.vertical)
                }
                
                // Image selection section - vertical layout
                VStack(spacing: 20) {
                    if showingResults {
                        // Show compact image view when displaying results
                        CompactImageView(title: "Top / Item 1", image: imageA)
                        CompactImageView(title: "Bottom / Item 2", image: imageB)
                    } else {
                        // Show full image selectors when not displaying results
                        ImageSelector(title: "Top / Item 1", selectedItem: $selectedItemA, image: $imageA)
                        ImageSelector(title: "Bottom / Item 2", selectedItem: $selectedItemB, image: $imageB)
                    }
                }
                
                // Show compare button only when not displaying results
                if !showingResults {
                    Button(action: performAnalysis) {
                        Label("Analyze Match", systemImage: "wand.and.stars")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                    }
                    .disabled(imageA == nil || imageB == nil || isAnalyzing)
                    .opacity((imageA == nil || imageB == nil || isAnalyzing) ? 0.6 : 1.0)
                }
                
                // Analysis progress
                if isAnalyzing {
                    ProgressView("Finding a match...")
                        .padding(.top, 20)
                }
                
                // Results section
                if let matchResult {
                    ResultView(text: matchResult, onReset: reset)
                        .padding(.top, showingResults ? 0 : 20)
                }
                
                if let errorMessage {
                    ErrorView(text: errorMessage, onReset: reset)
                        .padding(.top, showingResults ? 0 : 20)
                }
            }
            .padding()
        }
        .navigationTitle("Clothing Matcher")
        .animation(.easeInOut, value: showingResults)
        .animation(.easeInOut, value: isAnalyzing)
    }
    
    private func performAnalysis() {
        guard let imageA, let imageB else { return }
        
        isAnalyzing = true
        matchResult = nil
        errorMessage = nil
        
        Task {
            do {
                let resultText = try await service.analyzeMatch(itemA: imageA, itemB: imageB)
                self.matchResult = resultText
            } catch {
                self.errorMessage = "Analysis Failed: \(error.localizedDescription)"
            }
            isAnalyzing = false
        }
    }
    
    private func reset() {
        matchResult = nil
        errorMessage = nil
        // Optionally clear the selected images for a fresh start
        // selectedItemA = nil
        // selectedItemB = nil
        // imageA = nil
        // imageB = nil
    }
}

// MARK: - Reusable Subviews

private struct ImageSelector: View {
    let title: String
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var image: UIImage?
    
    // Define a constant for the image height
    private let imageHeight: CGFloat = 250
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
            VStack(spacing: 8) {
                if let image, image.size.width <= image.size.height {
                    // Vertical image: no border, use original height
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                } else {
                    // Horizontal image or no image: use fixed height container
                    ZStack {
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                            .frame(maxWidth: .infinity, minHeight: imageHeight, maxHeight: imageHeight)
                            .cornerRadius(12)
                        
                        if let image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: imageHeight)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                image = nil // Clear old image for better feedback
                guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                image = UIImage(data: data)
            }
        }
    }
}

private struct CompactImageView: View {
    let title: String
    let image: UIImage?
    
    // Define a constant for the compact image height
    private let compactImageHeight: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 8) {
            if let image, image.size.width <= image.size.height {
                // Vertical image: no border, use original height
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
            } else {
                // Horizontal image or no image: use fixed height container
                ZStack {
                    Rectangle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(maxWidth: .infinity, minHeight: compactImageHeight, maxHeight: compactImageHeight)
                        .cornerRadius(12)
                    
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: compactImageHeight)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private struct InstructionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tshirt.fill")
                .font(.system(size: 44))
                .foregroundColor(.accentColor)
            Text("How to Match Clothes")
                .font(.title2).fontWeight(.bold)
            Text("1. Tap the panels above to select photos of two clothing items.\n2. Tap 'Analyze Match' to get a style recommendation.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
    }
}

// Updated ResultView with better styling and clearer action
private struct ResultView: View {
    let text: String
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(.init(text)) // Render markdown
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onReset) {
                Label("Analyze New Outfit", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

// Updated ErrorView with better styling and clearer action
private struct ErrorView: View {
    let text: String
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundColor(.red)
            
            Text(text)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            Button(action: onReset) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.red.opacity(0.1))
        .cornerRadius(12)
    }
}
