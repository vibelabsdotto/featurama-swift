import SwiftUI
import FeaturamaSdk

struct ContentView: View {
    @EnvironmentObject var config: Config
    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    private var mintTheme: FeaturamaThemeOverrides {
        FeaturamaThemeOverrides(
            background: isDark ? Color(red: 0.0, green: 0.102, blue: 0.063) : Color(red: 0.94, green: 1.0, blue: 0.976),
            card: isDark ? Color(red: 0.039, green: 0.176, blue: 0.114) : Color(red: 0.878, green: 1.0, blue: 0.953),
            secondary: isDark ? Color(red: 0.082, green: 0.239, blue: 0.165) : Color(red: 0.816, green: 1.0, blue: 0.929),
            accentLight: isDark ? Color(red: 0.082, green: 0.239, blue: 0.165) : Color(red: 0.784, green: 0.969, blue: 0.91),
            accentForeground: .white,
            border: isDark ? Color(red: 0.110, green: 0.290, blue: 0.208) : Color(red: 0.604, green: 0.878, blue: 0.784),
            borderAccent: Color(red: 0.0, green: 0.8, blue: 0.65),
            gray100: isDark ? Color(red: 0.039, green: 0.176, blue: 0.114) : Color(red: 0.784, green: 0.969, blue: 0.91)
        )
    }

    var body: some View {
        if config.isConfigured {
            NavigationStack {
                FeaturamaView(
                    accentColor: Color(red: 0.0, green: 0.8, blue: 0.65),
                    theme: mintTheme,
                    onClose: nil
                )
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gear")
                                .font(.system(size: 20))
                        }
                    }
                }
            }
        } else {
            NavigationStack {
                VStack(spacing: 16) {
                    Text("Please configure your API key")
                        .foregroundStyle(.secondary)
                    NavigationLink("Open Settings") {
                        SettingsView()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .navigationTitle("Featurama Tester")
            }
        }
    }
}
