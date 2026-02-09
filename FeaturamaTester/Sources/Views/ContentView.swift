import SwiftUI
import FeaturamaSdk

struct ContentView: View {
    @EnvironmentObject var config: Config

    var body: some View {
        if config.isConfigured {
            NavigationStack {
                FeaturamaView(
                    accentColor: .indigo,
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
