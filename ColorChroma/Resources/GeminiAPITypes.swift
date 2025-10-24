// Models/GeminiAPITypes.swift

import Foundation

// MARK: - General Gemini API Structures (Shared)

/// A generic error response from the Gemini API.
struct GeminiError: Codable {
    let code: Int
    let message: String
}

// MARK: - Models for Multimodal (Image/Text) Requests

/// The top-level request structure for generating content with images.
struct GeminiMultimodalRequest: Codable {
    let contents: [MultimodalContent]
}

/// Represents a piece of content containing multiple parts (text, image).
struct MultimodalContent: Codable {
    let parts: [MultimodalPart]
}

/// A part of the content, which can be either text or image data.
struct MultimodalPart: Codable {
    let text: String?
    let inlineData: InlineData?
    
    // Initializer for text-only parts
    init(text: String) {
        self.text = text
        self.inlineData = nil
    }
    
    // Initializer for image-only parts
    init(inlineData: InlineData) {
        self.text = nil
        self.inlineData = inlineData
    }
}

/// Represents the base64-encoded image data.
struct InlineData: Codable {
    let mimeType: String
    let data: String
}

/// The response structure for multimodal requests.
struct GeminiMultimodalResponse: Codable {
    let candidates: [MultimodalCandidate]?
    let error: GeminiError?
}

/// A candidate response containing the generated content.
struct MultimodalCandidate: Codable {
    let content: MultimodalContent
}


// MARK: - Models for Chat (Conversation) Requests

/// The top-level request structure for chat conversations.
struct GeminiChatRequest: Codable {
    let contents: [ChatContent]
    let systemInstruction: ChatContent?
}

/// Represents a single message in a conversation.
struct ChatContent: Codable, Hashable {
    let role: String // "user" or "model"
    let parts: [ChatPart]
}

/// The text part of a chat message.
struct ChatPart: Codable, Hashable {
    let text: String
}

/// The response structure for chat requests.
struct GeminiChatResponse: Codable {
    let candidates: [ChatCandidate]?
    let error: GeminiError?
}

/// A candidate response containing the model's chat message.
struct ChatCandidate: Codable {
    let content: ChatContent
}
