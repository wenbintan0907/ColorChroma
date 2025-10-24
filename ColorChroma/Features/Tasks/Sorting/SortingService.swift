// Features/Sorting/SortingService.swift

import SwiftUI

@MainActor
class SortingService: ObservableObject {

    func getSortCategory(for image: UIImage) async throws -> String {
        let prompt = """
        You are a helpful laundry and item sorting assistant. Your only job is to look at the image of an item and classify it into one of the following broad color categories. Respond ONLY with the category name and nothing else.

        The categories are:
        - "Reds & Pinks"
        - "Blues & Purples"
        - "Greens"
        - "Yellows & Oranges"
        - "Browns"
        - "Blacks & Greys"
        - "Whites & Lights"
        - "Teals & Cyans"
        """
        
        // Prepare image data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeContentData)
        }
        let base64ImageString = imageData.base64EncodedString()

        // We can reuse the Multimodal request structs from our shared file
        let requestBody = GeminiMultimodalRequest(contents: [
            MultimodalContent(parts: [
                MultimodalPart(text: prompt),
                MultimodalPart(inlineData: InlineData(mimeType: "image/jpeg", data: base64ImageString))
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
        
        // Clean the response to ensure it's just the category name
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
