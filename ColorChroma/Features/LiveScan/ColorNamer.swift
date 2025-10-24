// ColorNamer.swift (Expanded Color Naming)

import UIKit

class ColorNamer {
    
    /// Generates a descriptive name for a given UIColor by analyzing its HSB components.
    func name(for color: UIColor) -> String {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        // --- Step 1: Handle Grayscale colors (including black and white) ---
        // These are determined primarily by brightness and very low saturation.
        if brightness < 0.1 { // Very dark
            return "Black"
        }
        if saturation < 0.1 { // Very desaturated
            if brightness > 0.95 {
                return "White"
            } else if brightness > 0.8 {
                return "Off-White" // Slightly off-white
            } else if brightness > 0.6 {
                return "Light Gray"
            } else if brightness < 0.3 {
                return "Dark Gray"
            } else {
                return "Gray"
            }
        }
        
        // --- Step 2: Determine the primary color family based on Hue ---
        // (Hue is 0-1, representing 0-360 degrees)
        let baseColorName: String
        
        // Red (0-15 degrees and 345-360 degrees)
        if hue < 0.04 || hue > 0.96 { // 0-14.4 or 345.6-360
            baseColorName = "Red"
        }
        // Orange (15-45 degrees)
        else if hue < 0.125 { // 14.4-45
            baseColorName = "Orange"
        }
        // Yellow (45-75 degrees)
        else if hue < 0.208 { // 45-75
            baseColorName = "Yellow"
        }
        // Chartreuse/Lime (75-95 degrees)
        else if hue < 0.264 { // 75-95
            baseColorName = "Lime Green"
        }
        // Green (95-165 degrees)
        else if hue < 0.458 { // 95-165
            baseColorName = "Green"
        }
        // Teal/Cyan (165-200 degrees)
        else if hue < 0.556 { // 165-200
            baseColorName = "Cyan"
        }
        // Blue (200-265 degrees)
        else if hue < 0.736 { // 200-265
            baseColorName = "Blue"
        }
        // Purple/Violet (265-300 degrees)
        else if hue < 0.833 { // 265-300
            baseColorName = "Purple"
        }
        // Magenta/Pink (300-345 degrees)
        else if hue < 0.96 { // 300-345.6
            baseColorName = "Magenta"
        }
        else {
            baseColorName = "Unknown Color" // Fallback
        }
        
        // --- Step 3: Add descriptive modifiers based on Saturation and Brightness ---
        // Ordered by precedence (e.g., if it's "Black" it won't be "Dark Red")
        
        // Special case for brown (often dark, desaturated orange/red)
        if (baseColorName == "Orange" || baseColorName == "Red" || baseColorName == "Yellow") && brightness < 0.6 && saturation > 0.2 {
            if saturation < 0.4 {
                return "Dull Brown"
            } else if brightness < 0.3 {
                return "Dark Brown"
            } else {
                return "Brown"
            }
        }
        
        // Special case for pink (light, desaturated red/magenta)
        if (baseColorName == "Red" || baseColorName == "Magenta") && brightness > 0.7 && saturation > 0.2 && saturation < 0.8 {
            if brightness > 0.9 {
                return "Light Pink"
            } else if saturation < 0.4 {
                return "Pale Pink"
            } else {
                return "Pink"
            }
        }
        
        // General modifiers
        var modifiers: [String] = []
        
        // Brightness modifiers
        if brightness > 0.9 {
            modifiers.append("Very Light")
        } else if brightness > 0.8 {
            modifiers.append("Light")
        } else if brightness < 0.2 {
            modifiers.append("Very Dark")
        } else if brightness < 0.4 {
            modifiers.append("Dark")
        } else if brightness < 0.5 {
             modifiers.append("Deep") // For richer, darker tones above "Dark"
        }
        
        // Saturation modifiers
        if saturation < 0.2 {
            modifiers.append("Muted") // Very little color
        } else if saturation < 0.4 {
            modifiers.append("Dull") // Less vibrant
        } else if saturation > 0.8 && brightness > 0.5 {
            modifiers.append("Vivid") // Very strong, pure color
        } else if saturation > 0.6 && brightness > 0.5 {
            modifiers.append("Bright") // Strong, but maybe not "Vivid"
        }
        
        // Combine modifiers and base color
        let combinedModifier = modifiers.joined(separator: " ")
        if combinedModifier.isEmpty {
            return baseColorName
        } else {
            return "\(combinedModifier) \(baseColorName)"
        }
    }
}
