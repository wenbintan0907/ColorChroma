// Features/ImageAnalysis/AnalysisResultView.swift (With matched widths)

import SwiftUI

struct AnalysisResultView: View {
    let result: AnalysisResult

    var body: some View {
        // Use GeometryReader to get the available screen width
        GeometryReader { geometry in
            
            // Define a horizontal padding value to be used for calculations
            let horizontalPadding: CGFloat = 20
            
            // Calculate the width for our content
            let contentWidth = geometry.size.width - (horizontalPadding * 2)

            // Main VStack to hold all content
            VStack(spacing: 24) {
                
                // Display the image that was analyzed
                Image(uiImage: result.image)
                    .resizable()
                    .scaledToFit()
                    // Set the frame width to our calculated content width
                    .frame(width: contentWidth)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    // The .padding(.horizontal) is no longer needed here

                // Display the results in a styled panel
                VStack(spacing: 8) {
                    Text(result.colorName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(result.hexCode)
                        .font(.headline)
                        .fontDesign(.monospaced)
                        .foregroundColor(.secondary)
                }
                .padding() // This inner padding gives the text breathing room
                // Set the frame width to match the image's width exactly
                .frame(width: contentWidth)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                // The .padding(.horizontal) is no longer needed here either

                Spacer()
            }
            .padding(.top, 20)
            // Ensure the VStack is centered within the GeometryReader
            .frame(width: geometry.size.width)
        }
        .navigationTitle("Analysis Result")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// Preview code for testing
// struct AnalysisResultView_Previews: PreviewProvider {
//     static var previews: some View {
//         // Create a sample result for the preview
//         let sampleResult = AnalysisResult(
//             image: UIImage(named: "rubiks-cube")!, // Make sure you have this image in your assets
//             colorName: "Vivid Blue",
//             hexCode: "#0047AB"
//         )
//
//         // Wrap in a NavigationView to see the title
//         NavigationView {
//             AnalysisResultView(result: sampleResult)
//         }
//     }
// }
