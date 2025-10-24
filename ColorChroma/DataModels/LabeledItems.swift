// DataModels/LabeledItem.swift

import Foundation
import SwiftUI
import SwiftData

@Model
final class LabeledItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var identifiedColor: String
    @Attribute(.externalStorage) var imageData: Data
    var timestamp: Date
    
    init(name: String, identifiedColor: String, image: UIImage) {
        self.id = UUID()
        self.name = name
        self.identifiedColor = identifiedColor
        // Store image as compressed JPEG data
        self.imageData = image.jpegData(compressionQuality: 0.8) ?? Data()
        self.timestamp = Date()
    }
}
