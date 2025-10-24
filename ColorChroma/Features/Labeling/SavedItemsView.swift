import SwiftUI
import SwiftData

struct SavedItemsView: View {
    @Query(sort: \LabeledItem.timestamp, order: .reverse) private var items: [LabeledItem]
    
    @Environment(\.modelContext) private var modelContext
    
    // State to track the item being edited, which will trigger the sheet
    @State private var itemToEdit: LabeledItem?
    
    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    // Wrap the entire VStack in a Button to make it tappable
                    Button {
                        itemToEdit = item // Set the item to be edited
                    } label: {
                        VStack(alignment: .leading, spacing: 0) {
                            // Vertical image display
                            Image(uiImage: normalizedImage(UIImage(data: item.imageData) ?? UIImage()))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxHeight: 180)
                                .clipped()
                                .clipShape(CustomRoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.headline)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                Text(item.identifiedColor)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(.plain) // Use plain style to not alter the card's appearance
                    .contextMenu {
                        // Add an Edit option to the context menu
                        Button {
                            itemToEdit = item
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        // Delete option
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Labeled Items")
        .overlay {
            if items.isEmpty {
                ContentUnavailableView(
                    "No Labeled Items",
                    systemImage: "tag.slash",
                    description: Text("Tap the '+' button to label a new item.")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: LabelingView()) {
                    Image(systemName: "plus")
                }
            }
        }
        // This sheet is presented whenever `itemToEdit` is not nil
        .sheet(item: $itemToEdit) { item in
            EditItemView(item: item)
        }
    }
    
    private func deleteItem(_ item: LabeledItem) {
        modelContext.delete(item)
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

// Custom rounded corner shape with unique name
struct CustomRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// UIImage Extension for Rotation with unique method name
extension UIImage {
    func rotateImage(radians: Float) -> UIImage? {
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
}

struct LabeledItemCard: View {
    let item: LabeledItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(uiImage: UIImage(data: item.imageData) ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                Text(item.identifiedColor)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding([.horizontal, .bottom], 12)
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
