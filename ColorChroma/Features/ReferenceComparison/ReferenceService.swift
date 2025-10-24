// Features/ReferenceComparison/ReferenceService.swift

import SwiftUI

@MainActor
class ReferenceService: ObservableObject {

    func compare(liveImage: UIImage, referenceImage: UIImage) async throws -> String {
        // --- PROMPT ENGINEERING FOR REFERENCE COMPARISON ---
        let prompt = """
        You are 'ChromaCompare', an AI assistant that helps users compare the color of an object to a reference image.

        You will be given two images: a "Reference Image" and a "Live Image". Your task is to analyze the color of the main subject in the "Live Image" and compare it to the main subject in the "Reference Image".

        Your response MUST follow this Markdown format:

        **Reference Color:**
        [Briefly describe the main color of the reference image. e.g., "A deep, healthy green."]

        **Current Color:**
        [Briefly describe the main color of the live image. e.g., "A muted, yellowish-green."]

        ---

        **Comparison & Advice:**
        [Provide a concise analysis. State if the colors are a "Close Match," "Similar," or "Different." Then, explain the difference in simple terms. For example, "The current leaf's color is much less vibrant and more yellow than the healthy reference leaf, which might indicate it needs water." or "This paint color is a very close match to your reference swatch."]
        """
        // --- END OF PROMPT ---
        
        // Prepare image data
        guard let liveImageData = liveImage.jpegData(compressionQuality: 0.8),
              let referenceImageData = referenceImage.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeContentData)
        }
        let base64LiveImage = liveImageData.base64EncodedString()
        let base64ReferenceImage = referenceImageData.base64EncodedString()

        // Reuse the Multimodal request structs
        // IMPORTANT: The prompt now refers to the images by their order.
        let requestBody = GeminiMultimodalRequest(contents: [
            MultimodalContent(parts: [
                MultimodalPart(text: prompt),
                // The first image sent is the "Reference Image"
                MultimodalPart(inlineData: InlineData(mimeType: "image/jpeg", data: base64ReferenceImage)),
                // The second image sent is the "Live Image"
                MultimodalPart(inlineData: InlineData(mimeType: "image/jpeg", data: base64LiveImage))
            ])
        ])

        // API Call Logic
        let apiKey = APIKey.default
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiMultimodalResponse.self, from: data)
        
        if let error = geminiResponse.error {
            throw NSError(domain: "GeminiAPI", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.message])
        }

        guard let text = geminiResponse.candidates?.first?.content.parts.first?.text else {
            throw URLError(.cannotParseResponse)
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
