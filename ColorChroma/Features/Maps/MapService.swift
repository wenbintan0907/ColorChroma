// Features/Maps/MapService.swift

import SwiftUI

@MainActor
class MapService: ObservableObject {

    func analyzeMap(image: UIImage) async throws -> String {
        // --- PROMPT ENGINEERING FOR MAPS & LEGENDS ---
        let prompt = """
                You are an expert cartographer and accessibility assistant specialized in transit maps. Your task is to meticulously analyze the provided image of a transit map and its legend.

                Follow these steps precisely for a colorblind user:
                1.  **Map Type & Overall Purpose:** Briefly identify the type of transit map (e.g., subway, metro, bus, train) and its primary purpose.
                2.  **Legend Analysis:** Locate and read the legend (or key) of the map. List each item from the legend, clearly stating its **color**, its **visual representation** (e.g., "solid line", "dashed line", "circle icon", "filled square"), and its **corresponding meaning or line name**. Be as specific as possible about the color.
                3.  **Network Summary & Connections:** Provide a concise summary of the overall transit network shown on the map. Mention the major lines, directions, and highlight any significant transfer points or key stations if they are visually prominent and marked by a specific color or symbol. Explicitly state the colors involved in connections where applicable.
                4.  **Important Symbols (Beyond Legend):** If there are any other highly visible, color-coded symbols or zones on the map (e.g., accessibility icons, zone colors, station types) not explicitly in the legend but crucial for navigation, briefly explain what they represent and their colors.

                Format your entire response strictly using Markdown.

                ### Map Overview
                [Type of map and its main purpose]

                ### Legend Breakdown
                - **[Color]:** [Visual representation] represents [Meaning/Line Name]. (Example: "Red solid line: Circle Line")
                - ... (continue for all legend items)

                ### Transit Network Summary
                [Concise description of the network, major lines, and connections/transfers, explicitly mentioning colors.]

                ### Key Map Symbols
                - **[Color] [Symbol Description]:** Represents [Meaning]. (Example: "Green circle icon: Wheelchair accessible station")
                """
            // --- END REFINED SYSTEM PROMPT ---
        
        // Prepare image data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw URLError(.cannotDecodeContentData)
        }
        let base64ImageString = imageData.base64EncodedString()

        // Reuse the Multimodal request structs from GeminiAPITypes.swift
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
        
        // Clean the response
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
