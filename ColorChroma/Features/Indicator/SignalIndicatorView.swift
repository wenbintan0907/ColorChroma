// Features/Indicator/SignalIndicatorView.swift (With Stable Layout Fix)

import SwiftUI

struct SignalIndicatorView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var indicatorService = IndicatorService()
    
    // UI State
    @State private var analysisResult: String?
    @State private var errorMessage: String?
    @State private var isAnalyzing = false
    
    var body: some View {
        ZStack {
            // --- FIX 1: STATIC CAMERA BACKGROUND ---
            // The CameraView is the bottom layer and ignores all safe areas.
            // It will never change size or position.
            CameraView(cameraManager: cameraManager)
                .ignoresSafeArea()
            
            // --- FIX 2: ABSOLUTELY POSITIONED RETICLE ---
            // Position the reticle at the exact center of the screen
            // This position is independent of other UI elements
            GeometryReader { geometry in
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 30, height: 30)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
            }
            .ignoresSafeArea()
            
            // --- FIX 3: BOTTOM-ALIGNED UI ---
            // Bottom controls are positioned at the bottom without affecting the reticle
            VStack {
                Spacer() // Pushes content to bottom
                bottomControls
            }
        }
        .onAppear { cameraManager.startSession() }
        .onDisappear { cameraManager.stopSession() }
        .navigationTitle("Indicator Scanner")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
    
    @ViewBuilder
    private var bottomControls: some View {
        VStack {
            if isAnalyzing {
                ProgressView("Analyzing...")
                    .padding(20)
                    .background(.regularMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 5)
            } else if let analysisResult {
                ResultCardView(resultText: analysisResult, onScanAgain: reset)
            } else if let errorMessage {
                ErrorCardView(errorText: errorMessage, onTryAgain: reset)
            } else {
                // --- FIX 4: FULL-WIDTH BUTTON ---
                Button(action: analyzeIndicator) {
                    Label("Analyze Light", systemImage: "bolt.fill")
                        .font(.headline).fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .shadow(radius: 5)
            }
        }
        .padding()
        .animation(.easeInOut, value: isAnalyzing)
        .animation(.easeInOut, value: analysisResult)
    }
    
    // MARK: - Logic (Unchanged)
    
    private func reset() {
        analysisResult = nil
        errorMessage = nil
    }
    
    private func analyzeIndicator() {
        guard !isAnalyzing else { return }
        
        guard let fullSnapshot = cameraManager.takeSnapshot() else {
            errorMessage = "Camera not ready. Please try again."
            return
        }
        
        isAnalyzing = true
        
        Task {
            let imageSize = fullSnapshot.size
            let cropSize = min(imageSize.width, imageSize.height) * 0.4
            let cropRect = CGRect(
                x: (imageSize.width - cropSize) / 2,
                y: (imageSize.height - cropSize) / 2,
                width: cropSize,
                height: cropSize
            )
            
            guard let croppedCGImage = fullSnapshot.cgImage?.cropping(to: cropRect) else {
                errorMessage = "Failed to crop image."
                isAnalyzing = false
                return
            }
            
            let croppedImage = UIImage(cgImage: croppedCGImage)
            
            do {
                let resultText = try await indicatorService.analyzeIndicator(image: croppedImage)
                self.analysisResult = resultText
            } catch {
                self.errorMessage = "Analysis Failed: \(error.localizedDescription)"
            }
            
            isAnalyzing = false
        }
    }
}

// --- DEDICATED SUBVIEWS (Unchanged) ---

struct ResultCardView: View {
    let resultText: String
    let onScanAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                Text(.init(resultText))
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 200)
            
            Button("Scan Again", action: onScanAgain)
                .font(.headline)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

struct ErrorCardView: View {
    let errorText: String
    let onTryAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.title)
            Text(errorText)
                .multilineTextAlignment(.center)
            Button("Try Again", action: onTryAgain)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}
