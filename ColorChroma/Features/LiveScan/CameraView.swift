// CameraView.swift (Corrected Version)

import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager

    func makeUIView(context: Context) -> PreviewView {
        let previewView = PreviewView()
        
        // Connect the manager's session to the preview view.
        previewView.videoPreviewLayer.session = cameraManager.session
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        return previewView
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        // This view is managed by the AVFoundation session, so no updates are needed from SwiftUI.
    }
}

// A custom UIView that exposes its AVCaptureVideoPreviewLayer.
class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
