// Features/FoodAid/FoodAidView.swift (With Keyboard Layout Fix)

import SwiftUI

struct FoodAidView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var foodAidService = FoodAidService()
    
    // UI State
    @State private var userQuestion: String = ""
    @State private var analysisResult: String?
    @State private var errorMessage: String?
    @State private var isAnalyzing = false
    @State private var keyboardHeight: CGFloat = 0
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            CameraView(cameraManager: cameraManager)
                .ignoresSafeArea()

            VStack {
                Spacer() // Pushes content to bottom
                
                // Content area for input/output
                contentArea
                    .padding(.horizontal, 16)
                    .padding(.bottom)
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
        .onAppear {
            cameraManager.startSession()
            setupKeyboardObservers()
        }
        .onDisappear {
            cameraManager.stopSession()
            removeKeyboardObservers()
        }
        .navigationTitle("Food & Cooking Aid")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
        .toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var contentArea: some View {
        VStack(spacing: 0) {
            if isAnalyzing {
                analysisLoadingView
            } else if let analysisResult {
                resultCard(text: analysisResult)
            } else if let errorMessage {
                errorCard(text: errorMessage)
            } else {
                inputCard
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .animation(.easeInOut, value: isAnalyzing)
        .animation(.easeInOut, value: analysisResult)
    }
    
    private var analysisLoadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.primary)
            
            Text("Analyzing food...")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(height: 100)
    }
    
    private var inputCard: some View {
        VStack(spacing: 16) {
            Text("What would you like to know?")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            TextField("e.g., Is this banana ripe?", text: $userQuestion, axis: .vertical)
                .padding(16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .focused($isTextFieldFocused)
                .lineLimit(1...4)
                .frame(minHeight: 44)
            
            Button(action: analyzeFood) {
                HStack {
                    Image(systemName: "sparkle.magnifyingglass")
                    Text("Analyze Food")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(userQuestion.isEmpty ? Color.blue : Color.blue)
                .cornerRadius(12)
            }
            .disabled(userQuestion.isEmpty)
            .animation(.easeInOut(duration: 0.2), value: userQuestion.isEmpty)
        }
    }
    
    private func resultCard(text: String) -> some View {
        VStack(spacing: 16) {
            ScrollView {
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }
            .frame(maxHeight: 200)
            
            Button("Ask Another Question") {
                reset()
            }
            .font(.headline)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private func errorCard(text: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.red)
            
            Text(text)
                .multilineTextAlignment(.center)
                .font(.body)
            
            Button("Try Again") {
                reset()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.red)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Logic
    
    private func reset() {
        analysisResult = nil
        errorMessage = nil
        userQuestion = ""
        isTextFieldFocused = false
    }
    
    private func analyzeFood() {
        isTextFieldFocused = false
        
        guard let snapshot = cameraManager.takeSnapshot() else {
            errorMessage = "Camera not ready. Please try again."
            return
        }
        
        isAnalyzing = true
        
        Task {
            do {
                let resultText = try await foodAidService.analyzeFood(image: snapshot, userQuestion: userQuestion)
                await MainActor.run {
                    self.analysisResult = resultText
                    self.isAnalyzing = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Analysis Failed: \(error.localizedDescription)"
                    self.isAnalyzing = false
                }
            }
        }
    }
}
