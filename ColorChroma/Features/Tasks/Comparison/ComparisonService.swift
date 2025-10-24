// Features/Comparison/ComparisonService.swift

import SwiftUI

@MainActor
class ComparisonService: ObservableObject {

    func compare(imageA: UIImage, imageB: UIImage) async throws -> String {
        // --- ADVANCED PROMPT ENGINEERING ---
        let prompt = """
        You are an expert accessibility assistant for users with colorblindness. Your task is to analyze the two images provided.

        Follow these steps:
        1.  In the first image, identify the main object and its most prominent color. State its color name and hex code.
        2.  In the second image, do the same: identify the main object and its most prominent color, including its name and hex code.
        3.  Finally, provide a "Comparison Analysis". In this analysis, you MUST state whether the two colors are easily distinguishable or if they are likely to be confused by someone with common colorblindness (like protanopia or deuteranopia). Explain *why* in simple terms, referencing their brightness or underlying color tones.

        Format your entire response using Markdown like this:

        **Item 1:**
        - **Object:** [Identified object name]
        - **Color:** [Color Name] ([#HEXCODE])

        **Item 2:**
        - **Object:** [Identified object name]
        - **Color:** [Color Name] ([#HEXCODE])

        **Comparison Analysis:**
        [Your detailed analysis here]
        """
        // --- END OF PROMPT ---

        // Prepare image data
        guard let imageDataA = imageA.jpegData(compressionQuality: 0.8),
              let imageDataB = imageB.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeContentData)
        }
        let base64ImageStringA = imageDataA.base64EncodedString()
        let base64ImageStringB = imageDataB.base64EncodedString()

        // Construct the request with two images and one prompt
        let requestBody = GeminiMultimodalRequest(contents: [
            MultimodalContent(parts: [
                MultimodalPart(text: prompt),
                MultimodalPart(inlineData: InlineData(mimeType: "image/jpeg", data: base64ImageStringA)),
                MultimodalPart(inlineData: InlineData(mimeType: "image/jpeg", data: base64ImageStringB))
            ])
        ])

        // API Call Logic (reusing what we have)
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
        
        return text
    }
}
