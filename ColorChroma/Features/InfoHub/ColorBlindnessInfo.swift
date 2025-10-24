// Models/ColorblindnessInfo.swift

import SwiftUI

// Re-using the enum from your SettingsModels.swift
// Make sure this file can access it.

struct ColorDeficiencyInfo: Identifiable, Hashable {
    let id: ColorblindnessType
    let name: String
    let description: String
    let impact: String
    let symptoms: String
    let prevalence: String
    let problematicColorCombinations: String
}

class InfoHubViewModel: ObservableObject {
    
    let infoData: [ColorblindnessType: ColorDeficiencyInfo] = [
        .normal: ColorDeficiencyInfo(
            id: .normal,
            name: "Normal Vision",
            description: "Individuals with normal trichromatic vision can distinguish between a full range of colors, typically around one million shades. This is due to having three types of functioning cone cells (red, green, and blue) in their retinas.",
            impact: "No impact on color perception. Able to see the full spectrum of colors as intended in designs, nature, and daily life.",
            symptoms: "N/A",
            prevalence: "The majority of the population.",
            problematicColorCombinations: "N/A",
        ),
        .protanopia: ColorDeficiencyInfo(
            id: .protanopia,
            name: "Protanopia",
            description: "A type of red-green colorblindness where the 'L-cones' (responsible for red light) are missing or non-functional. Reds appear dark, muted, and may be confused with greens or browns.",
            impact: "Difficulty distinguishing red from green. Red traffic lights may appear dim. Colors like purple may look like blue because the red component is not perceived.",
            symptoms: "Difficulty distinguishing between reds, greens, and browns. Bright red may look dark or brownish.",
            prevalence: "Affects about 1% of males.",
            problematicColorCombinations: "Red/green, purple/blue, brown/green.",
        ),
        .deuteranopia: ColorDeficiencyInfo(
            id: .deuteranopia,
            name: "Deuteranopia",
            description: "The most common type of red-green colorblindness where the 'M-cones' (responsible for green light) are missing or non-functional. Greens are confused with reds.",
            impact: "Difficulty telling reds and greens apart. Shades of orange, green, and brown can look very similar. It's often described as seeing the world in shades of yellow, blue, and gray.",
            symptoms: "Blues and yellows may be distinguishable, but reds and greens often appear as shades of yellow or brown.",
            prevalence: "Affects about 1% of males.",
            problematicColorCombinations: "Red/green, orange/yellow.",
        ),
        .tritanopia: ColorDeficiencyInfo(
            id: .tritanopia,
            name: "Tritanopia",
            description: "A rare type of blue-yellow colorblindness where the 'S-cones' (responsible for blue light) are missing or non-functional. Blues appear greenish, and yellows are seen as white or light gray.",
            impact: "Difficulty distinguishing blue from green, and yellow from violet. The world is seen primarily in shades of red, green, and gray.",
            symptoms: "Blues may appear as green, and yellow as grayish-white. Distant objects may be harder to distinguish based on color.",
            prevalence: "Very rare, affects less than 0.01% of males and females.",
            problematicColorCombinations: "Blue/green, yellow/violet.",
        ),
        .monochromacy: ColorDeficiencyInfo(
            id: .monochromacy,
            name: "Monochromacy (Achromatopsia)",
            description: "Also known as 'total colorblindness', this is an extremely rare condition where individuals cannot perceive any color at all. This is usually because two or all three types of cone cells are non-functional.",
            impact: "Vision is limited to shades of black, white, and gray, similar to a black and white photograph. This condition is often accompanied by other vision issues like light sensitivity (photophobia) and poor visual acuity.",
            symptoms: "Severe light sensitivity, blurry vision, and total inability to see colors. Objects are perceived only in black, white, and gray.",
            prevalence: "Extremely rare, affecting about 1 in 30,000 people.",
            problematicColorCombinations: "N/A, as all colors are perceived as shades of gray.",
        )
    ]
}
