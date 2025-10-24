// Features/Labeling/EditItemView.swift

import SwiftUI
import SwiftData

struct EditItemView: View {
    // The item being edited. @Bindable allows direct two-way editing.
    @Bindable var item: LabeledItem
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name of Object") {
                    TextField("Enter item name", text: $item.name)
                }
                
                Section("Color") {
                    TextField("Enter identified color", text: $item.identifiedColor)
                }
                
                Section("Image Preview") {
                    Image(uiImage: normalizedImage(UIImage(data: item.imageData) ?? UIImage()))
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Because we are using @Bindable, changes might be live.
                        // A more complex implementation could revert changes, but for now,
                        // just dismissing is a clean user experience.
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // SwiftData automatically saves the changes made via @Bindable.
                        // We just need to dismiss the sheet.
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    // Function to normalize image orientation
    private func normalizedImage(_ image: UIImage) -> UIImage {
        // If the image is already in portrait orientation, return as-is
        if image.size.height > image.size.width {
            return image
        }
        
        // Otherwise, rotate the image to portrait orientation
        let rotatedImage = image.rotateImage(radians: .pi/2)
        return rotatedImage ?? image // Return original image if rotation fails
    }
}
