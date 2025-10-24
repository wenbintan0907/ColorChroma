// ChatService.swift (With fix for trailing newlines)

import SwiftUI

// ... (Codable structs and ChatMessage struct remain the same) ...

// MARK: - Chat Message Model for UI
struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    var role: ChatRole
    var text: String
    
    enum ChatRole {
        case user
        case model
    }
}

// MARK: - Chat Service
@MainActor
class ChatService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    
    private let systemPrompt: String = """
    You are 'Chroma', a friendly, patient, and helpful AI assistant.
    Your primary purpose is to help users who are colorblind understand and describe colors in a more intuitive way.

    Follow these rules strictly:
    1.  When a user asks about a color (e.g., "What is teal?"), describe it using analogies to common objects, temperatures, or feelings. For example: "Teal is like the color of a deep tropical ocean, cooler than a standard green."
    2.  When comparing colors (e.g., "What's the difference between maroon and burgundy?"), highlight what makes them different in terms of brightness or their base colors (e.g., "Maroon is a dark brownish-red, like an autumn leaf. Burgundy is a dark reddish-purple, like red wine.").
    3.  If a user expresses frustration about color, be encouraging and positive.
    4.  Keep your answers concise and easy to read. Use short paragraphs.
    5.  Do not reveal that you are a language model or AI. You are Chroma.
    """
    
    func sendMessage(_ messageText: String) async {
        isLoading = true
        
        let userMessage = ChatMessage(role: .user, text: messageText)
        messages.append(userMessage)
        
        let systemInstruction = ChatContent(role: "user", parts: [ChatPart(text: systemPrompt)])
        
        let history = messages.map { message -> ChatContent in
            let role = (message.role == .user) ? "user" : "model"
            return ChatContent(role: role, parts: [ChatPart(text: message.text)])
        }
        
        let requestBody = GeminiChatRequest(contents: history, systemInstruction: systemInstruction)
        
        do {
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
            
            if let modelResponseText = geminiResponse.candidates?.first?.content.parts.first?.text {
                // --- THIS IS THE FIX ---
                // Clean the string to remove any leading/trailing empty lines
                let cleanedText = modelResponseText.trimmingCharacters(in: .whitespacesAndNewlines)
                let modelMessage = ChatMessage(role: .model, text: cleanedText)
                // --- END OF FIX ---
                messages.append(modelMessage)
                
            } else if let error = geminiResponse.error {
                throw NSError(domain: "GeminiAPI", code: error.code, userInfo: [NSLocalizedDescriptionKey: error.message])
            }
            
        } catch {
            let errorMessage = ChatMessage(role: .model, text: "Sorry, I ran into an error. Please try again. (\(error.localizedDescription))")
            messages.append(errorMessage)
        }
        
        isLoading = false
    }
}
