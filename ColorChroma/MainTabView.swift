import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // Tab 1: A clean home screen with its own NavigationStack
            HomeScreen()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Tab 2: The "Tools" screen with a list of all features
            TasksView()
                .tabItem {
                    Label("Tools", systemImage: "square.grid.2x2.fill")
                }
        }
        .tint(.blue) // App-wide tint color
    }
}
