// Features/Indicator/IndicatorService.swift (With length constraint in prompt)

import SwiftUI

@MainActor
class IndicatorService: ObservableObject {

    func analyzeIndicator(image: UIImage) async throws -> String {
        // --- PROMPT WITH NEW LENGTH CONSTRAINT ---
        let prompt = """
        You are 'SignalSight', an expert AI assistant specialized in helping colorblind users interpret indicator lights.
        Analyze the provided image, which is a close-up of an indicator light on a device.
        
        Do not output any cliche sentences like I will analyze the image of the indicator light.

        Your response should be structured clearly and concisely in Markdown format:

        **1. Identified Color & State:**
        State the precise color and its state (e.g., "Solid Green", "Flashing Red").

        **2. Common Interpretation:**
        Based on the context (if visible), provide the most likely interpretation. **Keep this interpretation to a maximum of 2-3 short sentences.**
        - Green: "Device is on/active", "OK/Normal operation", "Fully charged".
        - Red: "Error/Fault", "Warning/Attention required", "Low battery".
        - Yellow/Amber: "Warning/Caution", "Standby/Idle", "Charging".
        - Blue: "Bluetooth/Wireless connection", "Specific mode active".
        - White: "Power/On", "Ready".
        """
        // --- END OF PROMPT ---
        
        // ... (The rest of the service file remains exactly the same) ...
        
        // Prepare image data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeContentData)
        }
        let base64ImageString = imageData.base64EncodedString()
        
        let requestBody = GeminiMultimodalRequest(contents: [
            MultimodalContent(parts: [
                MultimodalPart(text: prompt),
                MultimodalPart(inlineData: InlineData(mimeType: "image/jpeg", data: base64ImageString))
            ])
        ])
        
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
