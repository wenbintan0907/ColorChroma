// Models/StandardColor.swift

import SwiftUI

struct StandardColor: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let color: UIColor
    
    var swiftUIColor: Color { Color(color) }
    var hexCode: String { color.toHex() ?? "#------" }
}

// NEW: A struct to represent a section of colors
struct ColorSection: Identifiable {
    let id = UUID()
    let name: String
    let colors: [StandardColor]
}

class StandardColorProvider {
    static let sections: [ColorSection] = [
        ColorSection(name: "Reds & Pinks", colors: [
            StandardColor(name: "Red", color: .systemRed),
            StandardColor(name: "Pink", color: .systemPink),
            StandardColor(name: "Crimson", color: UIColor(red: 0.86, green: 0.08, blue: 0.24, alpha: 1.0)),
            StandardColor(name: "Maroon", color: UIColor(red: 0.50, green: 0.00, blue: 0.00, alpha: 1.0)),
            StandardColor(name: "Salmon", color: UIColor(red: 0.98, green: 0.50, blue: 0.45, alpha: 1.0)),
            StandardColor(name: "Rose", color: UIColor(red: 1.00, green: 0.41, blue: 0.71, alpha: 1.0)),
            StandardColor(name: "Cherry", color: UIColor(red: 0.86, green: 0.18, blue: 0.18, alpha: 1.0)),
            StandardColor(name: "Burgundy", color: UIColor(red: 0.50, green: 0.00, blue: 0.13, alpha: 1.0)),
            StandardColor(name: "Scarlet", color: UIColor(red: 1.00, green: 0.14, blue: 0.00, alpha: 1.0)),
            StandardColor(name: "Candy Pink", color: UIColor(red: 1.00, green: 0.49, blue: 0.70, alpha: 1.0)),
            StandardColor(name: "Coral", color: UIColor(red: 1.00, green: 0.50, blue: 0.31, alpha: 1.0)),
        ]),
        ColorSection(name: "Oranges & Yellows", colors: [
            StandardColor(name: "Orange", color: .systemOrange),
            StandardColor(name: "Yellow", color: .systemYellow),
            StandardColor(name: "Gold", color: UIColor(red: 1.00, green: 0.84, blue: 0.00, alpha: 1.0)),
            StandardColor(name: "Amber", color: UIColor(red: 1.00, green: 0.75, blue: 0.00, alpha: 1.0)),
            StandardColor(name: "Peach", color: UIColor(red: 1.00, green: 0.80, blue: 0.65, alpha: 1.0)),
            StandardColor(name: "Mustard", color: UIColor(red: 0.81, green: 0.67, blue: 0.13, alpha: 1.0)),
            StandardColor(name: "Tangerine", color: UIColor(red: 0.97, green: 0.56, blue: 0.14, alpha: 1.0)),
            StandardColor(name: "Cantaloupe", color: UIColor(red: 1.00, green: 0.76, blue: 0.42, alpha: 1.0)),
            StandardColor(name: "Lemon", color: UIColor(red: 1.00, green: 1.00, blue: 0.00, alpha: 1.0)),
            StandardColor(name: "Saffron", color: UIColor(red: 0.96, green: 0.86, blue: 0.26, alpha: 1.0)),
        ]),
        ColorSection(name: "Greens", colors: [
            StandardColor(name: "Green", color: .systemGreen),
            StandardColor(name: "Lime", color: UIColor(red: 0.00, green: 1.00, blue: 0.00, alpha: 1.0)),
            StandardColor(name: "Teal", color: .systemTeal),
            StandardColor(name: "Olive", color: UIColor(red: 0.50, green: 0.50, blue: 0.00, alpha: 1.0)),
            StandardColor(name: "Mint", color: UIColor(red: 0.60, green: 1.00, blue: 0.80, alpha: 1.0)),
            StandardColor(name: "Forest", color: UIColor(red: 0.13, green: 0.55, blue: 0.13, alpha: 1.0)),
            StandardColor(name: "Chartreuse", color: UIColor(red: 0.50, green: 1.00, blue: 0.00, alpha: 1.0)),
            StandardColor(name: "Emerald", color: UIColor(red: 0.31, green: 0.78, blue: 0.47, alpha: 1.0)),
            StandardColor(name: "Pistachio", color: UIColor(red: 0.75, green: 0.60, blue: 0.42, alpha: 1.0)),
            StandardColor(name: "Seafoam", color: UIColor(red: 0.68, green: 1.00, blue: 0.76, alpha: 1.0)),
        ]),
        ColorSection(name: "Blues & Purples", colors: [
            StandardColor(name: "Blue", color: .systemBlue),
            StandardColor(name: "Indigo", color: .systemIndigo),
            StandardColor(name: "Purple", color: .systemPurple),
            StandardColor(name: "Navy", color: UIColor(red: 0.00, green: 0.00, blue: 0.50, alpha: 1.0)),
            StandardColor(name: "Sky Blue", color: UIColor(red: 0.53, green: 0.81, blue: 0.98, alpha: 1.0)),
            StandardColor(name: "Lavender", color: UIColor(red: 0.90, green: 0.90, blue: 0.98, alpha: 1.0)),
            StandardColor(name: "Plum", color: UIColor(red: 0.53, green: 0.13, blue: 0.38, alpha: 1.0)),
            StandardColor(name: "Turquoise", color: UIColor(red: 0.25, green: 0.88, blue: 0.82, alpha: 1.0)),
            StandardColor(name: "Teal Blue", color: UIColor(red: 0.00, green: 0.50, blue: 0.60, alpha: 1.0)),
            StandardColor(name: "Violet", color: UIColor(red: 0.93, green: 0.51, blue: 0.93, alpha: 1.0)),
            StandardColor(name: "Electric Blue", color: UIColor(red: 0.00, green: 0.53, blue: 1.00, alpha: 1.0)),
        ]),
        ColorSection(name: "Browns & Grays", colors: [
            StandardColor(name: "Brown", color: .brown),
            StandardColor(name: "Gray", color: .systemGray),
            StandardColor(name: "Black", color: .black),
            StandardColor(name: "White", color: .white),
            StandardColor(name: "Tan", color: UIColor(red: 0.82, green: 0.70, blue: 0.55, alpha: 1.0)),
            StandardColor(name: "Beige", color: UIColor(red: 0.96, green: 0.96, blue: 0.86, alpha: 1.0)),
            StandardColor(name: "Charcoal", color: UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)),
            StandardColor(name: "Slate", color: UIColor(red: 0.44, green: 0.50, blue: 0.56, alpha: 1.0)),
            StandardColor(name: "Coffee", color: UIColor(red: 0.39, green: 0.26, blue: 0.13, alpha: 1.0)),
            StandardColor(name: "Ash Gray", color: UIColor(red: 0.60, green: 0.60, blue: 0.60, alpha: 1.0)),
            StandardColor(name: "Copper", color: UIColor(red: 0.72, green: 0.45, blue: 0.20, alpha: 1.0)),
            StandardColor(name: "Mocha", color: UIColor(red: 0.60, green: 0.30, blue: 0.20, alpha: 1.0)),
        ]),
        ColorSection(name: "Pink & Purples", colors: [
            StandardColor(name: "Fuchsia", color: UIColor(red: 0.80, green: 0.00, blue: 0.80, alpha: 1.0)),
            StandardColor(name: "Magenta", color: UIColor(red: 1.00, green: 0.00, blue: 1.00, alpha: 1.0)),
            StandardColor(name: "Lavender Blush", color: UIColor(red: 1.00, green: 0.94, blue: 0.96, alpha: 1.0)),
            StandardColor(name: "Mauve", color: UIColor(red: 0.87, green: 0.60, blue: 0.69, alpha: 1.0)),
            StandardColor(name: "Orchid", color: UIColor(red: 0.85, green: 0.44, blue: 0.84, alpha: 1.0)),
            StandardColor(name: "Blush", color: UIColor(red: 1.00, green: 0.85, blue: 0.87, alpha: 1.0)),
            StandardColor(name: "Lavender Pink", color: UIColor(red: 0.98, green: 0.68, blue: 0.82, alpha: 1.0)),
            StandardColor(name: "Amethyst", color: UIColor(red: 0.60, green: 0.40, blue: 0.80, alpha: 1.0)),
            StandardColor(name: "Periwinkle", color: UIColor(red: 0.80, green: 0.80, blue: 1.00, alpha: 1.0)),
        ]),
        ColorSection(name: "Light & Dark", colors: [
            StandardColor(name: "Light Gray", color: UIColor(red: 0.83, green: 0.83, blue: 0.83, alpha: 1.0)),
            StandardColor(name: "Dark Gray", color: UIColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1.0)),
            StandardColor(name: "Light Blue", color: UIColor(red: 0.68, green: 0.85, blue: 0.90, alpha: 1.0)),
            StandardColor(name: "Dark Blue", color: UIColor(red: 0.00, green: 0.00, blue: 0.55, alpha: 1.0)),
            StandardColor(name: "Light Green", color: UIColor(red: 0.68, green: 1.00, blue: 0.49, alpha: 1.0)),
            StandardColor(name: "Dark Teal", color: UIColor(red: 0.00, green: 0.35, blue: 0.30, alpha: 1.0)),
            StandardColor(name: "Light Pink", color: UIColor(red: 1.00, green: 0.75, blue: 0.80, alpha: 1.0)),
            StandardColor(name: "Charcoal Gray", color: UIColor(red: 0.23, green: 0.23, blue: 0.23, alpha: 1.0)),
        ])
    ]
}

