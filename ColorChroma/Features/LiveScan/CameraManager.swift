// Features/LiveScan/CameraManager.swift (With the missing averageColor function included)

import AVFoundation
import UIKit
import SwiftUI

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Published Properties
    
    @Published var colorName: String = "Point at an object"
    @Published var hexCode: String = "#------"
    @Published var currentColor: UIColor = .clear
    @Published var error: Error?
    
    // MARK: - AVFoundation Properties
    
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.colorapp.sessionqueue")
    private let videoOutput = AVCaptureVideoDataOutput()
    private let colorNamer = ColorNamer()
    
    // MARK: - State, Snapshot & Smoothing Properties
    
    private var lastUpdateTime: Date = Date()
    private let updateInterval: TimeInterval = 0.1
    private var latestPixelBuffer: CVPixelBuffer?
    
    private var colorHistory: [UIColor] = []
    private let colorHistoryLength = 5 // Average over the last 5 frames
    
    override init() {
        super.init()
    }
    
    // MARK: - Public Control Methods
    
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.checkPermissions() { [weak self] granted in
                guard let self = self, granted else {
                    self?.handlePermissionDenied()
                    return
                }
                self.setupSession()
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    /// Takes a snapshot of the current camera feed.
    func takeSnapshot() -> UIImage? {
        guard let pixelBuffer = latestPixelBuffer else { return nil }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - Internal Setup
    
    private func checkPermissions(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: completion)
        default:
            completion(false)
        }
    }
    
    private func handlePermissionDenied() {
        DispatchQueue.main.async {
            self.error = NSError(domain: "CameraManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Camera access is required. Please enable it in Settings."])
        }
    }
    
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080
        
        for input in session.inputs { session.removeInput(input) }
        for output in session.outputs { session.removeOutput(output) }
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput) else {
            // ... error handling
            return
        }
        
        session.addInput(videoDeviceInput)
        
        do {
            try videoDevice.lockForConfiguration()
            videoDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 30)
            videoDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 30)
            videoDevice.unlockForConfiguration()
        } catch {
            print("Could not lock for configuration: \(error)")
        }
        
        if session.canAddOutput(videoOutput) {
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
    }
    
    // MARK: - Frame Processing (with color smoothing logic)
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.latestPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        guard Date().timeIntervalSince(lastUpdateTime) > updateInterval else { return }
        
        guard let pixelBuffer = self.latestPixelBuffer else { return }
        
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        
        let sampleSize = 10
        let startX = (width - sampleSize) / 2
        let startY = (height - sampleSize) / 2
        
        var totalRed: CGFloat = 0, totalGreen: CGFloat = 0, totalBlue: CGFloat = 0
        
        for y in startY..<(startY + sampleSize) {
            for x in startX..<(startX + sampleSize) {
                let pixelOffset = y * bytesPerRow + x * 4
                let b = CGFloat(baseAddress.load(fromByteOffset: pixelOffset, as: UInt8.self))
                let g = CGFloat(baseAddress.load(fromByteOffset: pixelOffset + 1, as: UInt8.self))
                let r = CGFloat(baseAddress.load(fromByteOffset: pixelOffset + 2, as: UInt8.self))
                totalRed += r; totalGreen += g; totalBlue += b
            }
        }
        
        let pixelCount = CGFloat(sampleSize * sampleSize)
        
        let singleFrameColor = UIColor(
            red: (totalRed / pixelCount) / 255.0,
            green: (totalGreen / pixelCount) / 255.0,
            blue: (totalBlue / pixelCount) / 255.0,
            alpha: 1.0
        )
        
        colorHistory.append(singleFrameColor)
        
        if colorHistory.count > colorHistoryLength {
            colorHistory.removeFirst()
        }
        
        guard let smoothedColor = averageColor(from: colorHistory) else { return }
        
        DispatchQueue.main.async {
            self.lastUpdateTime = Date()
            self.currentColor = smoothedColor
            self.colorName = self.colorNamer.name(for: smoothedColor)
            self.hexCode = smoothedColor.toHex() ?? "#------"
        }
    }
    
    /// Calculates the average color from an array of UIColors.
    private func averageColor(from colors: [UIColor]) -> UIColor? {
        guard !colors.isEmpty else { return nil }
        
        var totalRed: CGFloat = 0
        var totalGreen: CGFloat = 0
        var totalBlue: CGFloat = 0
        
        for color in colors {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
            // This safely gets the RGB components of a UIColor
            color.getRed(&r, green: &g, blue: &b, alpha: nil)
            totalRed += r
            totalGreen += g
            totalBlue += b
        }
        
        let count = CGFloat(colors.count)
        return UIColor(
            red: totalRed / count,
            green: totalGreen / count,
            blue: totalBlue / count,
            alpha: 1.0
        )
    }
}
