// APIKey.swift

import Foundation

enum APIKey {
    static var `default`: String {
        // --- Check 1: Make sure the file exists ---
        guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist") else {
            // All strings here are correctly terminated with a quote.
            fatalError("Couldn't find file 'GenerativeAI-Info.plist'. Please add it to your project.")
        }
        
        // --- Check 2: Make sure the file can be read as a dictionary ---
        let plist = NSDictionary(contentsOfFile: filePath)
        
        // --- Check 3: Make sure the key 'GEMINI_API_KEY' exists and is a String ---
        guard let value = plist?.object(forKey: "GEMINI_API_KEY") as? String else {
            // All strings here are correctly terminated with a quote.
            fatalError("Couldn't find key 'GEMINI_API_KEY' in 'GenerativeAI-Info.plist'.")
        }
        
        // --- Check 4: Make sure the user has replaced the placeholder key ---
        if value.starts(with: "YOUR_") || value.isEmpty {
            // All strings here are correctly terminated with a quote.
            fatalError("Please replace the placeholder value for 'GEMINI_API_KEY' in 'GenerativeAI-Info.plist' with an actual API key.")
        }
        
        return value
    }
}
