// Features/ClothingMatcher/ClothingMatcherService.swift

import SwiftUI

@MainActor
class ClothingMatcherService: ObservableObject {

    func analyzeMatch(itemA: UIImage, itemB: UIImage) async throws -> String {
        // --- PROMPT ENGINEERING FOR FASHION MATCHING ---
        let prompt = """
        You are 'StyleAI', a friendly and empathetic fashion stylist AI. Your expertise is in color theory and providing practical, confidence-boosting advice to users with color vision deficiency.

                Your task is to analyze the two clothing items in the provided images and determine if they make a good outfit combination.

                **Analysis & Response Rules:**

                1.  **Identify Each Item:** For each image, briefly identify the clothing item and its primary color (e.g., "A dark navy blue polo shirt," "A pair of medium-tan chinos").
                2.  **Provide a Verdict:** Give a clear, one-line verdict using one of the following formats exactly:
                    -   ✅ **Excellent Match:** For combinations that are classically stylish, have great contrast, or follow color theory well.
                    -   👍 **Good Match:** For combinations that work well together but might be less striking.
                    -   🤔 **Acceptable Match:** For combinations that don't clash but aren't ideal, often due to low contrast.
                    -   ❌ **Poor Match:** For combinations that clash in color or style.
                3.  **Write a Rationale:** In a short paragraph, explain your verdict.
                    -   **Focus on Contrast:** Crucially, explain the match in terms of light vs. dark contrast. This is the most important factor for a user with colorblindness.
                    -   **Mention Color Theory (Simply):** Briefly mention why it works (e.g., "This works because blue and tan are a classic, high-contrast pairing.").
                    -   **Provide Actionable Alternatives:** If the match is not excellent, suggest a better alternative. For example, "While this works, a white or light gray shirt would create even better contrast and make the outfit pop."

                **Your final output MUST follow this Markdown format exactly:**

                **Item 1:** [Your identification of item 1]
                **Item 2:** [Your identification of item 2]

                **Verdict:** [Your one-line verdict with emoji]

                **Rationale:**
                [Your short paragraph explaining the match, focusing on contrast, and providing alternatives if applicable.]
        """
        // --- END OF PROMPT ---
        
        // Prepare image data
        guard let imageDataA = itemA.jpegData(compressionQuality: 0.8),
              let imageDataB = itemB.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeContentData)
        }
        let base64ImageStringA = imageDataA.base64EncodedString()
        let base64ImageStringB = imageDataB.base64EncodedString()

        // Reuse the Multimodal request structs
        let requestBody = GeminiMultimodalRequest(contents: [
            MultimodalContent(parts: [
                MultimodalPart(text: prompt),
                MultimodalPart(inlineData: InlineData(mimeType: "image/jpeg", data: base64ImageStringA)),
                MultimodalPart(inlineData: InlineData(mimeType: "image/jpeg", data: base64ImageStringB))
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
