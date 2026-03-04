import SwiftUI
import FeaturamaSdk

struct ContentView: View {
    @EnvironmentObject var config: Config
    @State private var showFeaturama = false

    var body: some View {
        if config.isConfigured {
            NavigationStack {
                VStack {
                    Button("Feature Requests") {
                        showFeaturama = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .sheet(isPresented: $showFeaturama) {
                    FeaturamaView(
                        accentColor: .indigo,
                        onClose: { showFeaturama = false }
                    )
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
