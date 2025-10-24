// Models/SettingsModels.swift

import Foundation

enum ColorblindnessType: String, CaseIterable, Identifiable {
    case normal = "Normal Vision"
    case protanopia = "Protanopia (Red-Blind)"
    case deuteranopia = "Deuteranopia (Green-Blind)"
    case tritanopia = "Tritanopia (Blue-Blind)"
    case monochromacy = "Monochromacy (Achromatopsia)"
    
    var id: String { self.rawValue }
    
    var shortName: String {
            switch self {
            case .normal: return "Normal"
            case .protanopia: return "Protanopia"
            case .deuteranopia: return "Deuteranopia"
            case .tritanopia: return "Tritanopia"
            case .monochromacy: return "Monochromacy"
            }
        }
}

enum AppColorScheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
}
