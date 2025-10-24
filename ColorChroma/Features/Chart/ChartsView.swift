// ChartsView.swift

import SwiftUI
import PhotosUI

struct ChartsView: View {
    @StateObject private var service = ChartAnalyzerService()
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var chartImage: UIImage?
    @State private var analysisText: String?
    @State private var errorMessage: String?
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        if let chartImage {
                            // Display the selected image
                            Image(uiImage: chartImage)
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
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                if isAnalyzing {
                    loadingOverlay
                }
            }
            .navigationTitle("Chart Analyzer")
            .toolbar {
                // Add an upload button to the toolbar
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
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
    }
    
    // MARK: - UI Components
    
    private var getStartedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            Text("Upload a Chart")
                .font(.title2).fontWeight(.bold)
            Text("Tap the '+' button to select a bar chart, pie chart, or line graph from your photos.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    private func resultView(text: String) -> some View {
        VStack(alignment: .leading) {
            Text("Analysis")
                .font(.headline)
                .padding(.bottom, 4)
            Text(.init(text)) // Use .init(text) to render markdown
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func errorView(text: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(text)
                .font(.subheadline)
        }
        .padding()
        .background(.red.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var loadingOverlay: some View {
        ProgressView("Analyzing...")
            .progressViewStyle(CircularProgressViewStyle())
            .padding(25)
            .background(.regularMaterial)
            .cornerRadius(15)
            .shadow(radius: 10)
            .transition(.opacity.animation(.easeInOut))
    }
    
    // MARK: - Logic
    
    private func analyzeSelectedPhoto(item: PhotosPickerItem?) async {
        guard let item else { return }
        
        // Reset state
        isAnalyzing = true
        analysisText = nil
        errorMessage = nil
        
        // Load image
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            errorMessage = "Could not load image."
            isAnalyzing = false
            return
        }
        self.chartImage = uiImage
        
        // Analyze image
        do {
            let resultText = try await service.analyze(image: uiImage)
            self.analysisText = resultText
        } catch {
            self.errorMessage = "Analysis failed: \(error.localizedDescription)"
        }
        
        isAnalyzing = false
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}
