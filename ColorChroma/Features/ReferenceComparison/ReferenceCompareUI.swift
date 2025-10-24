// Features/ReferenceComparison/ReferenceCompareView.swift (With InstructionsView restored)

import SwiftUI
import PhotosUI

struct ReferenceCompareView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var referenceService = ReferenceService()
    
    // UI State
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var referenceImage: UIImage?
    
    @State private var analysisResult: String?
    @State private var errorMessage: String?
    @State private var isAnalyzing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Main comparison section
                HStack(spacing: 16) {
                    // Left side: Reference Image from Photo Library
                    VStack(spacing: 8) {
                        ImageSelector(selectedItem: $selectedPhotoItem, image: $referenceImage)
                        Text("Reference Image")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Right side: Live Camera Preview
                    VStack(spacing: 8) {
                        LiveCameraPreview(cameraManager: cameraManager)
                        Text("Live Item")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // --- THIS IS THE FIX ---
                // Show instructions only before the first analysis
                if analysisResult == nil && errorMessage == nil && !isAnalyzing {
                    InstructionsView()
                        .padding(.top, 10)
                }
                // --- END OF FIX ---
                
                // Compare button
                Button(action: performComparison) {
                    Label("Compare to Reference", systemImage: "arrow.left.arrow.right.circle.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .disabled(referenceImage == nil || isAnalyzing)
                .opacity((referenceImage == nil || isAnalyzing) ? 0.6 : 1.0)
                
                // Results section
                if isAnalyzing {
                    ProgressView("Comparing images...")
                        .padding(.top, 20)
                }
                
                if let analysisResult {
                    // We'll add a "Compare Another" button to the ResultView
                    ResultView(text: analysisResult, onReset: reset)
                        .padding(.top, 20)
                }
                
                if let errorMessage {
                    // And a "Try Again" button to the ErrorView
                    ErrorView(text: errorMessage, onReset: reset)
                        .padding(.top, 20)
                }
            }
            .padding()
        }
        .onAppear { cameraManager.startSession() }
        .onDisappear { cameraManager.stopSession() }
        .navigationTitle("Reference Comparison")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func performComparison() {
        guard let referenceImage else {
            errorMessage = "Please select a reference image first."
            return
        }
        
        guard let liveSnapshot = cameraManager.takeSnapshot() else {
            errorMessage = "Camera is not ready. Please try again."
            return
        }
        
        isAnalyzing = true
        analysisResult = nil
        errorMessage = nil
        
        Task {
            do {
                let resultText = try await referenceService.compare(liveImage: liveSnapshot, referenceImage: referenceImage)
                self.analysisResult = resultText
            } catch {
                self.errorMessage = "Comparison Failed: \(error.localizedDescription)"
            }
            isAnalyzing = false
        }
    }
    
    // Add a reset function to clear the results
    private func reset() {
        analysisResult = nil
        errorMessage = nil
    }
}

// MARK: - Reusable Subviews (With minor updates to support reset)

private struct ImageSelector: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var image: UIImage?
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color(.secondarySystemBackground))
                    Image(systemName: "photo.badge.plus")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
            }
            .aspectRatio(1.0, contentMode: .fit)
            .cornerRadius(12)
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                image = UIImage(data: data)
            }
        }
    }
}

private struct LiveCameraPreview: View {
    @ObservedObject var cameraManager: CameraManager
    
    var body: some View {
        ZStack {
            CameraView(cameraManager: cameraManager)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Circle()
                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                .frame(width: 30, height: 30)
        }
        .aspectRatio(1.0, contentMode: .fit)
    }
}

private struct InstructionsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.left.arrow.right.square.fill")
                .font(.system(size: 44))
                .foregroundColor(.accentColor)
            Text("How to Compare")
                .font(.title2).fontWeight(.bold)
            Text("1. Tap the left panel to select a reference image.\n2. Aim the camera at your current item.\n3. Tap 'Compare' to get an analysis.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // The button is now outside this view, so it's removed from here
        }
    }
}

// Updated ResultView to include a reset button
private struct ResultView: View {
    let text: String
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text(.init(text))
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Compare Another", action: onReset)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

// Updated ErrorView to include a reset button
private struct ErrorView: View {
    let text: String
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
            Text(text).font(.subheadline).multilineTextAlignment(.center)
            Button("Try Again", action: onReset)
        }
        .padding()
        .background(.red.opacity(0.1))
        .cornerRadius(12)
    }
}
