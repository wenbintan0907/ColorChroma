// Features/ColorDescription/DescriptionService.swift

import SwiftUI

@MainActor
class DescriptionService: ObservableObject {

    func describeColor(name: String, hex: String) async throws -> String {
        let prompt = """
        You are 'Chroma', an expert AI assistant that helps users understand and describe colors.
        The user has identified a color. Your task is to provide a rich, evocative description.

        The color is: **\(name)** (Hex: \(hex))

        Provide a description that includes:
        1.  **Analogies:** Compare the color to common, well-known objects, nature, or feelings (e.g., "like a ripe cherry," "the color of a clear summer sky," "a warm and cozy shade").
        2.  **Context:** Mention where this color is often seen (e.g., fashion, interior design, nature).
        3.  **Tone/Feeling:** Describe the mood the color evokes (e.g., "energetic and bold," "calm and peaceful," "elegant and sophisticated").

        Keep the response to a single, well-written paragraph. Do not repeat the color name or hex code in your response.
        """
        
        // We can reuse the Chat request structs since this is a text-only task
        let requestBody = GeminiChatRequest(contents: [
            ChatContent(role: "user", parts: [ChatPart(text: prompt)])
        ], systemInstruction: nil)

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
        
        let geminiResponse = try JSONDecoder().decode(GeminiChatResponse.self, from: data)
        
        if let error = geminiResponse.error {
            throw NSError(domain: "GeminiAPI", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.message])
        }

        guard let text = geminiResponse.candidates?.first?.content.parts.first?.text else {
            throw URLError(.cannotParseResponse)
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
