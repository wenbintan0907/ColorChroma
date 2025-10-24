// ChatView.swift (Updated with Typing Indicator)

import SwiftUI

struct ChatView: View {
    @StateObject private var chatService = ChatService()
    @State private var userInput: String = ""
    
    // A unique ID for our typing indicator so we can scroll to it
    private let typingIndicatorId = "typingIndicator"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat message list
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(chatService.messages) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                            }
                            
                            // --- Typing indicator appears here ---
                            if chatService.isLoading {
                                TypingIndicatorView()
                                    .id(typingIndicatorId)
                                    .transition(.opacity.animation(.easeInOut))
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatService.messages) { _, _ in
                        // When a new *model message* arrives, scroll to it
                        if let lastMessageId = chatService.messages.last?.id {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: chatService.isLoading) { _, isLoading in
                        // When loading *starts*, scroll to the typing indicator
                        if isLoading {
                            withAnimation {
                                scrollViewProxy.scrollTo(typingIndicatorId, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // --- REMOVED: The old ProgressView is gone ---
                
                // Input area
                HStack(spacing: 12) {
                    TextField("Ask about a color...", text: $userInput, axis: .vertical)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                    }
                    .disabled(userInput.isEmpty || chatService.isLoading)
                }
                .padding()
                .background(.regularMaterial)
            }
            .navigationTitle("Chat")
            .onAppear {
                if chatService.messages.isEmpty {
                    chatService.messages.append(ChatMessage(role: .model, text: "Hello! I'm Chroma. How can I help you with colors today?"))
                }
            }
        }
    }
    
    func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let messageToSend = userInput
        userInput = ""
        
        Task {
            await chatService.sendMessage(messageToSend)
        }
    }
}

// MARK: - Chat Message Subview (No changes needed here)

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            Text(message.text)
                .padding(12)
                .background(message.role == .user ? Color.blue : Color(.systemGray5))
                .foregroundColor(message.role == .user ? .white : .primary)
                .cornerRadius(16)
            
            if message.role == .model {
                Spacer()
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
