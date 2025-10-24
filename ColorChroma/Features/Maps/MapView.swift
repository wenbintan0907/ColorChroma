// Features/Maps/MapView.swift

import SwiftUI
import PhotosUI

struct MapView: View {
    @StateObject private var service = MapService()
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var mapImage: UIImage?
    @State private var analysisText: String?
    @State private var errorMessage: String?
    @State private var isAnalyzing = false
    
    var body: some View {
        ZStack {
            // Main content area
            ScrollView {
                VStack(spacing: 20) {
                    // Display the selected map image
                    if let mapImage {
                        Image(uiImage: mapImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .shadow(radius: 5)
                    }
                    
                    // Display the analysis result or initial prompt
                    if let analysisText {
                        resultView(text: analysisText)
                    } else if errorMessage == nil && !isAnalyzing {
                        getStartedView
                    }
                    
                    // Display any errors
                    if let errorMessage {
                        errorView(text: errorMessage)
                    }
                }
                .padding(.vertical)
            }
            
            // Loading overlay
            if isAnalyzing {
                ProgressView("Analyzing Map...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(25)
                    .background(.regularMaterial)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
        .navigationTitle("Transit Map")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.headline)
                }
                .disabled(isAnalyzing)
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                await analyzeSelectedPhoto(item: newItem)
            }
        }
    }
    
    // MARK: - UI Components
    
    private var getStartedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "map.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            Text("Upload a Map")
                .font(.title2).fontWeight(.bold)
            Text("Tap the icon above to select a map with a legend from your photos.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    private func resultView(text: String) -> some View {
        VStack(alignment: .leading) {
            // Use Text(.init(text)) to render the Markdown from Gemini
            Text(.init(text))
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func errorView(text: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
            Text(text).font(.subheadline)
        }
        .padding()
        .background(.red.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Logic
    
    private func analyzeSelectedPhoto(item: PhotosPickerItem?) async {
        guard let item else { return }
        
        isAnalyzing = true
        analysisText = nil
        errorMessage = nil
        
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            errorMessage = "Could not load image."
            isAnalyzing = false
            return
        }
        self.mapImage = uiImage
        
        do {
            let resultText = try await service.analyzeMap(image: uiImage)
            self.analysisText = resultText
        } catch {
            self.errorMessage = "Analysis failed: \(error.localizedDescription)"
        }
        
        isAnalyzing = false
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MapView()
        }
    }
}
