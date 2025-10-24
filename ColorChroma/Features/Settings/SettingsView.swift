import SwiftUI

// MARK: - Main Settings View
struct SettingsView: View {
    // --- User Preferences ---
    @AppStorage("appColorScheme") private var selectedColorScheme: AppColorScheme = .system
    @AppStorage("colorblindnessType") private var selectedColorblindness: ColorblindnessType = .normal
    
    // --- Static App Information ---
    private struct AppInfo {
        static let developerName = "Tan Wen Bin"
        static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    
    // --- URLs ---
    private struct Links {
        static let developerWebsite = "https://your_website.com"
        static let twitter = "https://x.com/your_username"
        static let privacyPolicy = "https://your_website.com/privacy"
        static let termsOfUse = "https://your_website.com/terms"
    }
    
    // --- Dismiss Environment Value ---
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Appearance Section
                Section("Appearance") {
                    Picker("Theme", selection: $selectedColorScheme) {
                        ForEach(AppColorScheme.allCases) { scheme in
                            Text(scheme.rawValue).tag(scheme)
                        }
                    }
                }
                
                // MARK: - Links Section
                Section("Connect") {
                    SettingsLinkRow(
                        iconName: "at",
                        iconColor: .blue,
                        title: "Follow on X",
                        link: Links.twitter
                    )
                    SettingsLinkRow(
                        iconName: "globe",
                        iconColor: .gray,
                        title: "Developer Website",
                        link: Links.developerWebsite
                    )
                }

                // MARK: - Legal Section
                Section("Legal") {
                    SettingsLinkRow(
                        iconName: "doc.text.fill",
                        iconColor: .secondary,
                        title: "Terms of Use",
                        link: Links.termsOfUse
                    )
                    SettingsLinkRow(
                        iconName: "shield.lefthalf.filled",
                        iconColor: .green,
                        title: "Privacy Policy",
                        link: Links.privacyPolicy
                    )
                }

                // MARK: - About Section
                Section("About") {
                    HStack {
                        Text("Developer")
                        Spacer()
                        Text(AppInfo.developerName)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(AppInfo.appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss() // Dismiss the view when tapped
                        
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .preferredColorScheme(mapColorScheme())
    }
    
    private func mapColorScheme() -> ColorScheme? {
        switch selectedColorScheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil // `nil` tells SwiftUI to use the system setting.
        }
    }
}

// MARK: - Reusable Link Row Component
private struct SettingsLinkRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let link: String

    var body: some View {
        Link(destination: URL(string: link)!) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(iconColor)
                    Image(systemName: iconName)
                        .font(.body.weight(.medium))
                        .foregroundColor(.white)
                }
                .frame(width: 32, height: 32)

                Text(title)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
            }
        }
        .foregroundColor(.primary)
    }
}


// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
