// Features/ImageAnalysis/ImageAnalyzer.swift (Simplified - No Object Recognition)

import SwiftUI
import Vision // Still needed for Saliency
import CoreImage // Still needed for image processing helpers

@MainActor
class ImageAnalyzer: ObservableObject {
    @Published var isAnalyzing = false
    
    // We only need the saliency request now.
    private var saliencyRequest = VNGenerateAttentionBasedSaliencyImageRequest()
    private let colorNamer = ColorNamer()

    init() {
        // The setupClassificationModel() call is no longer needed and is removed.
    }
    
    func analyze(image: UIImage) async -> AnalysisResult? {
        isAnalyzing = true
        defer { isAnalyzing = false }

        guard let cgImage = image.cgImage else { return nil }
        
        // We only need to perform the saliency request.
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([saliencyRequest])
        } catch {
            print("Failed to perform Vision saliency request: \(error)")
            return nil
        }
        
        // The classification processing block is removed. We go straight to color analysis.
        
        // Process the saliency and color result.
        guard let saliencyResult = saliencyRequest.results?.first,
              let salientPoint = findRawSalientPoint(in: saliencyResult.pixelBuffer, originalImageSize: image.size),
              let averageColor = getAverageColor(around: salientPoint, in: cgImage) else {
            // If color analysis fails, return nil.
            return nil
        }
        
        let colorName = colorNamer.name(for: averageColor)
        let hexCode = averageColor.toHex() ?? "#------"
        
        // Create the result without the objectDescription.
        return AnalysisResult(image: image, colorName: colorName, hexCode: hexCode)
    }
    
    // --- Helper functions remain the same ---
    
    private func findRawSalientPoint(in saliencyMap: CVPixelBuffer, originalImageSize: CGSize) -> CGPoint? {
        CVPixelBufferLockBaseAddress(saliencyMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(saliencyMap, .readOnly) }

        guard let saliencyBaseAddress = CVPixelBufferGetBaseAddress(saliencyMap) else { return nil }
        
        let saliencyMapWidth = CVPixelBufferGetWidth(saliencyMap)
        let saliencyMapHeight = CVPixelBufferGetHeight(saliencyMap)
        let saliencyBytesPerRow = CVPixelBufferGetBytesPerRow(saliencyMap)
        
        var maxSaliency: Float = 0.0
        var mostSalientSaliencyPoint: CGPoint? = nil
        
        for ySaliency in 0..<saliencyMapHeight {
            for xSaliency in 0..<saliencyMapWidth {
                let saliencyPixelOffset = ySaliency * saliencyBytesPerRow + xSaliency * MemoryLayout<Float>.size
                let saliencyValue = saliencyBaseAddress.load(fromByteOffset: saliencyPixelOffset, as: Float.self)
                
                if saliencyValue > maxSaliency {
                    maxSaliency = saliencyValue
                    mostSalientSaliencyPoint = CGPoint(x: xSaliency, y: ySaliency)
                }
            }
        }
        
        guard let salientPoint = mostSalientSaliencyPoint else { return nil }
        
        let mappedXOriginal = CGFloat(salientPoint.x) / CGFloat(saliencyMapWidth) * originalImageSize.width
        let mappedYOriginal = CGFloat(salientPoint.y) / CGFloat(saliencyMapHeight) * originalImageSize.height
        
        return CGPoint(x: mappedXOriginal, y: mappedYOriginal)
    }

    private func getAverageColor(around point: CGPoint, in cgImage: CGImage, sampleSize: Int = 20) -> UIColor? {
        guard let pixelData = cgImage.dataProvider?.data,
              let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData) else { return nil }

        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow
        let width = cgImage.width
        let height = cgImage.height

        var totalRed: CGFloat = 0
        var totalGreen: CGFloat = 0
        var totalBlue: CGFloat = 0
        var pixelCount: CGFloat = 0
        
        let startX = Int(point.x) - sampleSize / 2
        let startY = Int(point.y) - sampleSize / 2

        for y in startY..<(startY + sampleSize) {
            for x in startX..<(startX + sampleSize) {
                if x >= 0 && x < width && y >= 0 && y < height {
                    let pixelOffset = y * bytesPerRow + x * bytesPerPixel
                    let r = CGFloat(data[pixelOffset])
                    let g = CGFloat(data[pixelOffset + 1])
                    let b = CGFloat(data[pixelOffset + 2])
                    
                    totalRed += r
                    totalGreen += g
                    totalBlue += b
                    pixelCount += 1
                }
            }
        }
        
        if pixelCount == 0 { return nil }
        
        return UIColor(red: (totalRed / pixelCount) / 255.0,
                       green: (totalGreen / pixelCount) / 255.0,
                       blue: (totalBlue / pixelCount) / 255.0,
                       alpha: 1.0)
    }
}
