import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var config: Config

    @State private var editingApiKey: String = ""
    @State private var editingBaseUrl: String = ""
    @State private var showingSavedAlert = false

    var body: some View {
        Form {
            Section("API Configuration") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("API Key")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("fm_live_xxxxxxxxxxxxxxxxxxxx", text: $editingApiKey)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.asciiCapable)
                        #endif
                        .autocorrectionDisabled()
                        .font(.system(size: 14, design: .monospaced))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Base URL")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("http://localhost:5001", text: $editingBaseUrl)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        #endif
                        .autocorrectionDisabled()
                        .font(.system(size: 14, design: .monospaced))
                }
            }

            Section {
                Button("Save Configuration") {
                    config.apiKey = editingApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                    config.baseUrl = editingBaseUrl.trimmingCharacters(in: .whitespacesAndNewlines)
                    showingSavedAlert = true
                }
                .disabled(editingApiKey.isEmpty || editingBaseUrl.isEmpty)
            }

            Section("Validation") {
                HStack {
                    Text("API Key Valid")
                    Spacer()
                    Image(systemName: config.apiKey.hasPrefix("fm_live_") ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(config.apiKey.hasPrefix("fm_live_") ? .green : .red)
                }
                HStack {
                    Text("Base URL Valid")
                    Spacer()
                    Image(systemName: URL(string: config.baseUrl) != nil ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(URL(string: config.baseUrl) != nil ? .green : .red)
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            editingApiKey = config.apiKey
            editingBaseUrl = config.baseUrl
        }
        .alert("Configuration Saved", isPresented: $showingSavedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The SDK client has been reconfigured.")
        }
    }
}
