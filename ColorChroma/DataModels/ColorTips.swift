// Models/ColorTips.swift

import Foundation

struct ColorTip: Identifiable {
    let id = UUID()
    let text: String
}

struct ColorTips {
    static let all: [ColorTip] = [
        ColorTip(text: "Crimson red has more blue tones than scarlet, which can make it appear darker or different to some colorblind individuals."),
        ColorTip(text: "For red-green colorblindness, differentiating purple (red + blue) from blue can be difficult because the red component is less visible."),
        ColorTip(text: "To create high contrast, pair a 'light' color with a 'dark' color. This is more reliable than pairing colors like red and green."),
        ColorTip(text: "Teal is a mix of blue and green. Depending on the type of colorblindness, it might look more like a shade of gray or blue."),
        ColorTip(text: "Many people with colorblindness learn to associate colors with their typical brightness. For example, they know that the 'green' traffic light is usually at the bottom."),
        ColorTip(text: "Olive green is a 'dull' color, meaning it has low saturation. It can easily be confused with shades of brown or gray."),
        ColorTip(text: "When buying clothes, taking a photo and using a color analysis tool can help you confirm colors like navy blue versus black."),
        ColorTip(text: "Lighting can drastically change color perception. Colors that look distinct in bright daylight may blend together under indoor lighting."),
        ColorTip(text: "Brown is essentially a dark, desaturated orange. This is why it can be hard to distinguish from certain shades of red and green."),
        ColorTip(text: "Blue is often one of the easiest colors to identify for people with the most common forms of red-green colorblindness."),
        ColorTip(text: "Look for non-color cues! The shape of a stop sign or the position of a light can be more reliable than its color alone.")
    ]
}
