// Features/ImageAnalysis/AnalysisResult.swift

import SwiftUI

// This struct holds the data returned by the ImageAnalyzer.
// Making it Identifiable and Hashable is required for modern SwiftUI navigation.
struct AnalysisResult: Identifiable, Hashable {
    let id = UUID()
    let image: UIImage
    let colorName: String
    let hexCode: String
    
    // Conformance to Hashable requires an implementation of `hash(into:)`
    // We just need to hash the unique ID.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Conformance to Equatable requires an implementation of `==`
    // Two results are the same if their unique IDs are the same.
    static func == (lhs: AnalysisResult, rhs: AnalysisResult) -> Bool {
        return lhs.id == rhs.id
    }
}
