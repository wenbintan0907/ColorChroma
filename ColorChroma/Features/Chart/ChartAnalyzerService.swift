// ChartAnalyzerService.swift (Updated to use shared models)

import SwiftUI

@MainActor
class ChartAnalyzerService: ObservableObject {
    
    func analyze(image: UIImage) async throws -> String {
        let prompt = """
        You are an expert data analyst. Concisely describe the key insights, trends, or main points from the following chart image.
        Focus on what the chart is showing, what the values are, and what conclusions can be drawn.
        Crucially, for accessibility, whenever a color is used to represent data, clearly state its color *and* its corresponding label from the legend. For example, if a blue bar represents "Q1 Sales", describe it as "The blue bar, representing Q1 Sales, indicates...". If the red line shows "Temperature", describe it as "The red line (Temperature) shows a sharp increase...".
        """
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeContentData)
        }
        let base64ImageString = imageData.base64EncodedString()
        
        // Use the new, specific request struct name
        let requestBody = GeminiMultimodalRequest(contents: [
            MultimodalContent(parts: [
                MultimodalPart(text: prompt),
                MultimodalPart(inlineData: InlineData(mimeType: "image/jpeg", data: base64ImageString))
            ])
        ])
        
        let apiKey = APIKey.default
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Use the new, specific response struct name
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
