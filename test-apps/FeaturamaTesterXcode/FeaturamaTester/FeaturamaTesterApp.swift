import SwiftUI
import FeaturamaSdk

@main
struct FeaturamaTesterApp: App {
    @StateObject private var config = Config()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(config)
                .onAppear {
                    configureSdk()
                }
                .onChange(of: config.apiKey) {
                    configureSdk()
                }
                .onChange(of: config.baseUrl) {
                    configureSdk()
                }
        }
    }

    private func configureSdk() {
        guard config.isConfigured, let url = URL(string: config.baseUrl) else { return }
        try? FeaturamaSdk.configure(apiKey: config.apiKey, baseURL: url)
    }
}
