// Features/Labeling/LabelingView.swift (Redesigned UI with Vertical Image)

import SwiftUI
import SwiftData

struct LabelingView: View {
    // SwiftData Environment & Dismiss Action
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Camera & Analysis
    @StateObject private var cameraManager = CameraManager()
    
    // UI State
    @State private var capturedImage: UIImage?
    @State private var identifiedColor: String?
    @State private var itemName: String = ""
    @State private var isSaving = false
    
    var body: some View {
        // Use a ZStack to layer the UI over the camera feed
        ZStack {
            // Layer 1: The Camera View
            CameraView(cameraManager: cameraManager)
                .ignoresSafeArea()
                .opacity(capturedImage == nil ? 1.0 : 0.0) // Show only in live mode

            // This background is only visible on the saving screen
            if capturedImage != nil {
                Color(.systemGroupedBackground).ignoresSafeArea()
            }
            
            // Layer 2: The Main UI
            if let image = capturedImage {
                // Show the saving interface if an image has been captured
                savingInterface(for: image)
                    .transition(.opacity)
            } else {
                // Show the live camera interface
                liveCameraInterface
                    .transition(.opacity)
            }
        }
        .onAppear { cameraManager.startSession() }
        .onDisappear { cameraManager.stopSession() }
        .navigationTitle(capturedImage == nil ? "Label Item" : "Confirm & Save")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar) // Hide the tab bar
        .toolbar {
            if capturedImage != nil {
                ToolbarItem(placement: .primaryAction) {
                    Button("Retake") {
                        resetCapture()
                    }
                }
            }
        }
    }
    
    // MARK: - Live Camera UI (Modeled after Sorting Assistant)
    
    private var liveCameraInterface: some View {
        VStack {
            // Live color readout at the top
            Text(cameraManager.colorName)
                .font(.headline)
                .fontWeight(.medium)
                .padding(10)
                .background(.regularMaterial)
                .cornerRadius(10)
                .padding(.top)
            
            Spacer()
            
            // Aiming reticle
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 30, height: 30)

            Spacer()
            
            // Capture Button at the bottom
            Button(action: capturePhoto) {
                Label("Capture Item", systemImage: "camera.fill")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
        }
    }
    
    // MARK: - Saving Interface UI
    
    private func savingInterface(for image: UIImage) -> some View {
        VStack(spacing: 24) {
            // Updated image display for vertical orientation
            Image(uiImage: normalizedImage(image))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 400)
                .cornerRadius(16)
                .shadow(radius: 5)
            
            VStack(spacing: 4) {
                Text("Identified Color").font(.caption).foregroundColor(.secondary)
                Text(identifiedColor ?? "Unknown").font(.title2).fontWeight(.semibold)
            }
            
            TextField("Enter item name (e.g., 'Work Shirt')", text: $itemName)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            
            Spacer()
            
            // Save button is always at the bottom
            Button(action: saveItem) {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Label("Save Labeled Item", systemImage: "tag.fill")
                }
            }
            .font(.headline)
            .fontWeight(.bold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(itemName.isEmpty ? .gray : .blue)
            .foregroundColor(.white)
            .cornerRadius(16)
            .disabled(itemName.isEmpty || isSaving)
        }
        .padding()
    }
    
    // MARK: - Functions
    
    private func normalizedImage(_ image: UIImage) -> UIImage {
        // If the image is already in portrait orientation, return as-is
        if image.size.height > image.size.width {
            return image
        }
        
        // Otherwise, rotate the image to portrait orientation
        let rotatedImage = image.rotate(radians: .pi/2)
        return rotatedImage ?? image // Return original image if rotation fails
    }
    
    private func capturePhoto() {
        withAnimation {
            self.capturedImage = cameraManager.takeSnapshot()
            self.identifiedColor = cameraManager.colorName
        }
    }
    
    private func resetCapture() {
        withAnimation {
            capturedImage = nil
            identifiedColor = nil
            itemName = ""
        }
    }
    
    private func saveItem() {
        guard let image = capturedImage, let color = identifiedColor, !itemName.isEmpty else { return }
        
        isSaving = true
        
        let newItem = LabeledItem(name: itemName, identifiedColor: color, image: image)
        modelContext.insert(newItem)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - UIImage Extension for Rotation
extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func fixedOrientation() -> UIImage {
            guard imageOrientation != .up else { return self }
            
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(in: CGRect(origin: .zero, size: size))
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return normalizedImage ?? self
        }
}
