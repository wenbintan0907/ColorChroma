// Features/ColorTest/ColorTestView.swift

import SwiftUI

struct ColorTestView: View {
    // This closure will be provided by the OnboardingView to dismiss the whole flow.
    var onComplete: (() -> Void)? = nil
    
    @State private var testPlates = TestProvider.getTestPlates()
    @State private var currentPlateIndex = 0
    @State private var score = 0
    
    // State to manage the UI flow
    @State private var selectedAnswer: String?
    @State private var showResult = false
    
    var currentPlate: TestPlate {
        testPlates[currentPlateIndex]
    }
    
    var body: some View {
        Group {
            if showResult {
                // Pass the score, total, and completion handler to the results view
                TestResultsView(
                    score: score,
                    totalQuestions: testPlates.count,
                    onComplete: onComplete
                )
                .transition(.opacity)
            } else {
                testInterface
            }
        }
        // A single, subtle animation for all state changes in this view
        .animation(.easeInOut(duration: 0.3), value: currentPlateIndex)
        .animation(.easeInOut(duration: 0.3), value: selectedAnswer)
        .animation(.easeInOut(duration: 0.3), value: showResult)
    }
    
    // MARK: - Main Test UI
    
    private var testInterface: some View {
        VStack(spacing: 20) {
            header
            plateImageView
            
            // This container ensures the options and feedback card have the same width
            VStack(spacing: 12) {
                if selectedAnswer == nil {
                    answerOptionsView
                        .transition(.opacity)
                } else {
                    feedbackCard
                        .transition(.opacity)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Perception Test")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - UI Components
    
    private var header: some View {
        VStack(spacing: 8) {
            Text("Question \(currentPlateIndex + 1) of \(testPlates.count)")
                .font(.headline)
                .foregroundColor(.secondary)
                .id("question_\(currentPlateIndex)") // Helps animate text content change
                .transition(.opacity)

            ProgressView(value: Double(currentPlateIndex + 1), total: Double(testPlates.count))
                .progressViewStyle(LinearProgressViewStyle())
                .tint(.accentColor)
        }
    }
    
    private var plateImageView: some View {
        Image(currentPlate.imageName)
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.systemGray5), lineWidth: 4))
            .shadow(radius: 10)
            .padding()
            .id(currentPlate.id) // Helps animate the image change
            .transition(.opacity)
    }
    
    private var answerOptionsView: some View {
        ForEach(currentPlate.options, id: \.self) { option in
            Button(action: {
                selectAnswer(option)
            }) {
                Text(option)
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)
            .disabled(selectedAnswer != nil)
        }
    }
    
    private var feedbackCard: some View {
        let explanationText = currentPlate.answerExplanations[selectedAnswer ?? ""] ?? "No feedback available."
        
        return FeedbackCard(
            isCorrect: selectedAnswer == currentPlate.correctAnswer,
            explanation: explanationText
        )
    }
    
    // MARK: - Logic
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        if answer == currentPlate.correctAnswer {
            score += 1
        }
        
        // Auto-advance after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            nextQuestion()
        }
    }
    
    private func nextQuestion() {
        if currentPlateIndex < testPlates.count - 1 {
            currentPlateIndex += 1
            selectedAnswer = nil
        } else {
            showResult = true
        }
    }
}

// MARK: - Subviews

struct FeedbackCard: View {
    let isCorrect: Bool
    let explanation: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .orange)
                    .font(.title)
                Text(isCorrect ? "Correct!" : "A Common Perception")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text(explanation)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

struct TestResultsView: View {
    let score: Int
    let totalQuestions: Int
    var onComplete: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Test Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You correctly identified")
                .font(.title3)
            
            Text("\(score) out of \(totalQuestions)")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    Image(systemName: "exclamationmark.shield.fill").foregroundColor(.orange).font(.title)
                    Text("**Non-Diagnostic Disclaimer**")
                }
                Text("This is an interactive learning tool, not a medical diagnosis. Screen settings, lighting, and individual vision can affect results. For a formal assessment, please consult an eye care professional.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            Spacer()
            
            Button(onComplete == nil ? "Back to Tasks" : "Continue to App") {
                onComplete?()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        // Hide the default back button if we're in the onboarding flow
        .navigationBarBackButtonHidden(onComplete != nil)
    }
}
