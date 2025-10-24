// Features/Sorting/SortingAssistantView.swift

import SwiftUI

struct SortingAssistantView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var sortingService = SortingService()
    
    // State for managing the UI
    @State private var identifiedPiles: [String] = []
    @State private var lastScannedPile: String?
    @State private var isAnalyzing = false
    @State private var errorMessage: String?
    
    // For the pulse animation on the result
    @State private var shouldPulse = false
    
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    // --- UPDATED BODY WITH LAYOUT FIX ---
    var body: some View {
        ZStack {
            // Layer 1: Live camera feed, always at the back
            CameraView(cameraManager: cameraManager)
                .ignoresSafeArea()
                .onAppear { cameraManager.startSession() }
                .onDisappear { cameraManager.stopSession() }

            // Layer 2: A ZStack for all UI overlays
            ZStack {
                // The aiming reticle is now in the ZStack, so it will always be centered.
                
                Spacer()
                
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 30, height: 30)
                
                Spacer()

                // The rest of the UI is in a VStack
                VStack {
                    // Top Area for Piles
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(identifiedPiles, id: \.self) { pile in
                                Text(pile)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 60)
                                    .background(.regularMaterial)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, lineWidth: lastScannedPile == pile ? 4 : 0)
                                    )
                                    .scaleEffect(lastScannedPile == pile && shouldPulse ? 1.05 : 1.0)
                            }
                        }
                        .padding()
                    }
                    .padding(.top, 10)
                    .frame(maxHeight: 250)

                    Spacer() // Pushes the bottom content down

                    // Bottom Area for Error and Button
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .padding()
                            .background(.red.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .transition(.opacity)
                    }

                    Button(action: scanItem) {
                        if isAnalyzing {
                            ProgressView().tint(.white)
                        } else {
                            Label("Scan Item", systemImage: "plus.viewfinder")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isAnalyzing ? Color.gray : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .padding([.horizontal, .bottom])
                    .disabled(isAnalyzing)
                }
            }
        }
        .navigationTitle("Sorting Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    // ... (scanItem function and preview remain the same) ...
    private func scanItem() {
        guard let snapshot = cameraManager.takeSnapshot() else {
            errorMessage = "Could not get image from camera."
            return
        }
        
        isAnalyzing = true
        errorMessage = nil
        
        Task {
            do {
                let category = try await sortingService.getSortCategory(for: snapshot)
                
                if !identifiedPiles.contains(category) {
                    identifiedPiles.append(category)
                    identifiedPiles.sort()
                }
                
                lastScannedPile = category
                
                withAnimation(.easeInOut(duration: 0.2)) {
                    shouldPulse = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeInOut) {
                        shouldPulse = false
                    }
                }
                
            } catch {
                errorMessage = "Analysis Failed. Please try again."
                print("Sorting analysis failed: \(error.localizedDescription)")
            }
            
            isAnalyzing = false
        }
    }
}
