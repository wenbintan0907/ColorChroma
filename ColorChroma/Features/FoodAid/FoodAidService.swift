// Features/FoodAid/FoodAidService.swift

import SwiftUI

@MainActor
class FoodAidService: ObservableObject {

    func analyzeFood(image: UIImage, userQuestion: String) async throws -> String {
        // --- PROMPT ENGINEERING FOR FOOD ANALYSIS ---
        // This prompt sets the context and combines with the user's specific question.
        let systemPreamble = """
        You are 'ChefSight', an expert AI culinary assistant designed to assist users with food-related tasks. Your role is to analyze images provided by users and offer insightful guidance based on visual cues, such as color, texture, and shape.
        
        Task Examples:

        Assessing the ripeness of produce (e.g., fruits and vegetables) based on color and texture.

        Determining the doneness of cooked food (e.g., meats, eggs, or baked goods) by comparing visual changes like color shifts or texture changes.

        Offering comparisons between live or real-time images and reference images of the desired state (e.g., ideal ripeness or perfectly cooked food).
        
        User's question: "\(userQuestion)"
        
        Your analysis:
        Focus on clear visual cues from the image provided.

        Offer actionable advice based on the current state of the food and compare it to desired outcomes when applicable.
        """
        // --- END OF PROMPT ---
        
        // Prepare image data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeContentData)
        }
        let base64ImageString = imageData.base64EncodedString()

        // Reuse the Multimodal request structs
        let requestBody = GeminiMultimodalRequest(contents: [
            MultimodalContent(parts: [
                MultimodalPart(text: systemPreamble),
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
            let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
            print("API Error: HTTP Status Code \((response as? HTTPURLResponse)?.statusCode ?? -1), Body: \(responseBody)")
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
