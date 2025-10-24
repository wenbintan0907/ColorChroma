// Features/Home/HomeViewModel.swift

import SwiftUI

class HomeViewModel: ObservableObject {
    
    /// Holds the randomly selected color tip to be displayed on the home screen.
    @Published var dailyTip: ColorTip
    
    /// The list of actions available to the user from the home screen grid.
    @Published var quickActions: [QuickAction]
    
    init() {
        // --- 1. Select a random tip for the day ---
        // It fetches a random element from our static list of tips.
        // The nil-coalescing operator `??` provides a fallback if the list is empty.
        self.dailyTip = ColorTips.all.randomElement() ?? ColorTip(text: "Welcome! Explore the features to learn more about color.")
        
        // --- 2. Define the quick actions ---
        // This array defines the buttons that appear on the home screen.
        self.quickActions = [
            QuickAction(title: "Camera", iconName: "camera.viewfinder", color: .red),
            QuickAction(title: "Compare", iconName: "arrow.left.arrow.right.circle.fill", color: Color(red: 0.4, green: 0.5, blue: 0.2)),
            QuickAction(title: "Analyze", iconName: "photo.on.rectangle.angled", color: .purple),
            QuickAction(title: "Sort", iconName: "square.stack.3d.up.fill", color: Color(red: 0.2, green: 0.7, blue: 0.8))
        ]
    }
}
