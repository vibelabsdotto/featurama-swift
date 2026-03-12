import Foundation
import SwiftUI

final class Config: ObservableObject {
    private static let apiKeyKey = "featurama_api_key"
    private static let baseUrlKey = "featurama_base_url"
    private static let defaultBaseUrl = "http://localhost:5001"

    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: Self.apiKeyKey)
        }
    }

    @Published var baseUrl: String {
        didSet {
            UserDefaults.standard.set(baseUrl, forKey: Self.baseUrlKey)
        }
    }

    var isConfigured: Bool {
        !apiKey.isEmpty && apiKey.hasPrefix("fm_live_") && URL(string: baseUrl) != nil
    }

    init() {
        self.apiKey = UserDefaults.standard.string(forKey: Self.apiKeyKey) ?? ""
        self.baseUrl = UserDefaults.standard.string(forKey: Self.baseUrlKey) ?? Self.defaultBaseUrl
    }
}
