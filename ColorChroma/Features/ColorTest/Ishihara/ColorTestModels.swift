// Features/ColorTest/ColorTestModels.swift

import Foundation

struct TestPlate: Identifiable {
    let id = UUID()
    let imageName: String
    let correctAnswer: String
    
    // NEW: A dictionary to hold specific feedback for each possible answer.
    // The key is the answer string (e.g., "74"), and the value is the explanation.
    let answerExplanations: [String: String]
    
    // A computed property to easily get all possible options.
    var options: [String] {
        // Return the keys of the dictionary, sorted for consistent order.
        return answerExplanations.keys.sorted()
    }
}

class TestProvider {
    static func getTestPlates() -> [TestPlate] {
        let plates = [
            TestPlate(
                imageName: "ishihara_12",
                correctAnswer: "12",
                answerExplanations: [
                    "12": "Correct! This is a control plate that most people can see clearly.",
                    "72": "This answer is incorrect. Most people see '12'.",
                    "Nothing": "This is a control plate. Seeing nothing may indicate a significant color vision issue."
                ]
            ),
            TestPlate(
                imageName: "ishihara_8",
                correctAnswer: "8",
                answerExplanations: [
                    "8": "Correct! People with normal color vision typically see an '8'.",
                    "3": "Those with red green color blindness see a 3.",
                    "Nothing": "Those with total color blindness see nothing."
                ]
            ),
            TestPlate(
                imageName: "ishihara_74",
                correctAnswer: "74",
                answerExplanations: [
                    "74": "Correct! Those with normal color vision see a '74'.",
                    "21": "Those with red green color blindness see a 21.",
                    "Nothing": "Those with total color blindness see nothing."
                ]
            ),
            TestPlate(
                imageName: "ishihara_5",
                correctAnswer: "5",
                answerExplanations: [
                    "5": "Correct! Individuals with normal vision typically see a '5'.",
                    "2": "Those with red green color blindness see a 2.",
                    "Nothing": "Not being able to see a number here can be an indicator of red-green color deficiency."
                ]
            ),
            TestPlate(
                imageName: "ishihara_42",
                correctAnswer: "42",
                answerExplanations: [
                    "42": "Correct! Individuals with normal vision typically see a '42'.",
                    "2, faint 4": "Red color blind (protanopia) people will see a 2, mild red color blind people (prontanomaly) will also faintly see a number 4",
                    "4, faint 2": "Green color blind (deuteranopia) people will see a 4, mild green color blind people (deuteranomaly) may also faintly see a number 2."
                ]
            ),
            TestPlate(
                imageName: "ishihara_26",
                correctAnswer: "26",
                answerExplanations: [
                    "26": "Correct! Individuals with normal vision typically see a '26'.",
                    "6, faint 2": "Red color blind (protanopia) people will see a 6, mild red color blind people (prontanomaly) will also faintly see a number 2.",
                    "2, faint 6": "Green color blind (deuteranopia) people will see a 2, mild green color blind people (deuteranomaly) may also faintly see a number 6."
                ]
            ),
            TestPlate(
                imageName: "ishihara_73",
                correctAnswer: "73",
                answerExplanations: [
                    "73": "Correct! Individuals with normal vision typically see a '73'.",
                    "Nothing": "The majority of color blind people cannot see this number clearly."
                ]
            ),
            TestPlate(
                imageName: "ishihara_16",
                correctAnswer: "16",
                answerExplanations: [
                    "16": "Correct! Individuals with normal vision typically see a '16'.",
                    "Nothing": "The majority of color blind people cannot see this number clearly.",
                ]
            ),
            TestPlate(
                imageName: "ishihara_7",
                correctAnswer: "7",
                answerExplanations: [
                    "7": "Correct! Individuals with normal vision typically see a '7'.",
                    "Nothing": "The majority of color blind people cannot see this number clearly.",
                ]
            ),
            TestPlate(
                imageName: "ishihara_45",
                correctAnswer: "45",
                answerExplanations: [
                    "45": "Correct! Individuals with normal vision typically see a '45'.",
                    "Nothing": "The majority of color blind people cannot see this number clearly.",
                ]
            ),
        ]
        return plates.shuffled()
    }
}
