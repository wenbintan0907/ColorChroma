// Models/HomeModels.swift

import SwiftUI

// Represents a single item in the "Recents" list
struct RecentScan: Identifiable {
    let id = UUID()
    let imageName: String
    let timestamp: String
    let description: String
}

// Represents a single button in the "Quick Actions" grid
struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let color: Color
}
