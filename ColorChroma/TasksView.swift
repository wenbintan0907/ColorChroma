// Features/Tasks/TasksView.swift (With Categorized Sections)

import SwiftUI

// --- DATA MODELS ---

struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let iconColor: Color
}

// NEW: A struct to represent a section of tasks
struct TaskSection: Identifiable {
    let id = UUID()
    let title: String
    let tasks: [TaskItem]
}


// --- MAIN VIEW ---

struct TasksView: View {
    // --- NEW: Data is now organized into sections ---
    let taskSections: [TaskSection] = [
        TaskSection(title: "Color Analysis & Matching", tasks: [
            TaskItem(title: "Clothing Matcher", description: "AI helps determine if two items match.", iconName: "tshirt.fill", iconColor: .pink),
            TaskItem(title: "Compare Colors", description: "Compare the colors of two selected items.", iconName: "arrow.left.arrow.right.circle.fill", iconColor: .orange),
            TaskItem(title: "Reference Comparison", description: "Compare an item's color with a reference image.", iconName: "square.2.stack.3d.bottom.filled", iconColor: .indigo)
        ]),
        
        TaskSection(title: "AI Assistance", tasks: [
            TaskItem(title: "Chart Analyzer", description: "AI analyzes and explains charts.", iconName: "chart.pie.fill", iconColor: .purple),
            TaskItem(title: "Food & Cooking Aid", description: "Get AI assistance for ripeness or doneness checks.", iconName: "carrot.fill", iconColor: .orange)
        ]),
        
        TaskSection(title: "Practical Tools", tasks: [
            TaskItem(title: "Sorting Assistant", description: "Group items by similar colors (e.g., laundry).", iconName: "square.stack.3d.up.fill", iconColor: .green),
            TaskItem(title: "Indicator Scanner", description: "Identify the color and meaning of indicator lights.", iconName: "lightbulb.led.fill", iconColor: .blue)
        ]),
        
        TaskSection(title: "Learning & Resources", tasks: [
            TaskItem(title: "Labeled Items", description: "View your saved items and their color labels.", iconName: "tag.fill", iconColor: .gray),
            TaskItem(title: "Color Reference", description: "Lookup standard colors and reference swatches.", iconName: "paintpalette.fill", iconColor: .cyan),
            TaskItem(title: "Perception Tests", description: "Test and explore your color perception.", iconName: "gamecontroller.fill", iconColor: .teal),
            TaskItem(title: "Colorblindness Info", description: "Learn about types of color vision deficiencies.", iconName: "info.circle.fill", iconColor: .purple)
        ])
    ]

    
    var body: some View {
        NavigationStack {
            // Use a List that can iterate over the new sectioned data
            List {
                ForEach(taskSections) { section in
                    // Create a Section view for each TaskSection
                    Section(header: Text(section.title)) {
                        ForEach(section.tasks) { task in
                            NavigationLink {
                                destinationView(for: task)
                            } label: {
                                TaskRow(task: task)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped) // This style looks great with sections
            .navigationTitle("All Tools")
        }
    }
    
    // Helper to determine the destination view for clean navigation logic
    @ViewBuilder
    private func destinationView(for task: TaskItem) -> some View {
        switch task.title {
        // AI-Powered
        case "Clothing Matcher": ClothingMatcherView()
        case "Chart Analyzer": ChartsView()
        case "Food & Cooking Aid": FoodAidView()
        // Real-World Tools
        case "Sorting Assistant": SortingAssistantView()
        case "Indicator & Signal": SignalIndicatorView()
        case "Reference Comparison": ReferenceCompareView()
        case "Compare Colors": ColorComparisonView()
        // Library & Learning
        case "Labeled Items": SavedItemsView()
        case "Color Reference": ColorReferenceView()
        case "Perception Tests": ColorTestView()
        case "Colorblindness Info": InfoHubView()
        // Placeholder for any other tasks
        default: Text("\(task.title) - View Not Found")
        }
    }
}

// MARK: - Reusable View for each Task Row
private struct TaskRow: View {
    let task: TaskItem
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: task.iconName)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(task.iconColor)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) { // Added a small spacing for clarity
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // --- FIX: Updated the description text modifiers ---
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2) // Allow up to 2 lines
                    .fixedSize(horizontal: false, vertical: true) // Allow the view to grow vertically
            }
        }
        .padding(.vertical, 10) // Increased vertical padding slightly for more breathing room
    }
}
