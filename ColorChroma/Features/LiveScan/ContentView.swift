// Features/LiveScan/ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var descriptionService = DescriptionService() // The new service
    
    // State to control the detail sheet
    @State private var showDetailSheet = false
    @State private var detailedDescription: String?
    @State private var isFetchingDescription = false
    
    var body: some View {
        ZStack {
            // Layer 1: Live camera feed
            CameraView(cameraManager: cameraManager)
                .ignoresSafeArea()

            // Layer 2: UI Elements
            VStack {
                Spacer()
                
                // Aiming reticle
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 30, height: 30)

                Spacer()
                
                // The bottom panel is now a button that triggers the detail sheet
                Button {
                    fetchAndShowDetails()
                } label: {
                    bottomInfoPanel
                }
            }
        }
        .onAppear { cameraManager.startSession() }
        .onDisappear { cameraManager.stopSession() }
        .navigationTitle("Camera")
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar) // Hide main tab bar on this screen
        // This presents the ColorDetailSheet when showDetailSheet is true
        .sheet(isPresented: $showDetailSheet) {
            ColorDetailSheet(
                color: cameraManager.currentColor, // Pass the detected color
                colorName: cameraManager.colorName,
                description: detailedDescription,
                isLoading: isFetchingDescription
            )
            // Use a medium detent for a modern "half sheet" look
            .presentationDetents([.medium])
        }
    }
    
    /// The bottom panel that shows live color info and acts as a button.
    private var bottomInfoPanel: some View {
        VStack(spacing: 8) {
            HStack {
                // Main color name - allow multiline and align to leading
                Text(cameraManager.colorName)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil) // Allow unlimited lines
                    .frame(maxWidth: .infinity, alignment: .leading) // Align to leading edge
                
                // An icon to indicate the panel is expandable
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.body.weight(.semibold))
            }
            .foregroundColor(.primary)
            
            // Hex code, aligned to the left
            Text(cameraManager.hexCode)
                .font(.headline.monospaced())
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(.regularMaterial)
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.bottom, 8)
        .animation(.easeInOut(duration: 0.2), value: cameraManager.colorName)
    }
    
    /// Fetches the detailed color description and presents the sheet.
    private func fetchAndShowDetails() {
        // 1. Reset state and show the sheet immediately with a loading indicator
        detailedDescription = nil
        isFetchingDescription = true
        showDetailSheet = true
        
        // 2. Grab the current color info to avoid it changing while fetching
        let name = cameraManager.colorName
        let hex = cameraManager.hexCode
        
        // 3. Start the asynchronous network call
        Task {
            do {
                let description = try await descriptionService.describeColor(name: name, hex: hex)
                // On success, update the description
                self.detailedDescription = description
            } catch {
                // On failure, provide a user-facing error message
                self.detailedDescription = "Sorry, a description could not be generated for this color. Please check your connection and try again."
                print("Error fetching description: \(error)")
            }
            // 4. In either case, turn off the loading indicator
            self.isFetchingDescription = false
        }
    }
}

// Previews for development
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
