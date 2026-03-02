import Foundation

/// Configuration for the Featurama SDK
public struct Configuration: Sendable {
    /// The API key for authentication (must start with "fm_live_")
    public let apiKey: String

    /// The base URL for the Featurama API
    public let baseURL: URL

    /// Timeout interval for network requests in seconds
    public let timeoutInterval: TimeInterval

    /// Optional app version override (auto-detected from Bundle if nil)
    public let appVersion: String?

    /// Optional app build override (auto-detected from Bundle if nil)
    public let appBuild: String?

    /// The required prefix for valid API keys
    public static let apiKeyPrefix = "fm_live_"

    /// Default base URL for the Featurama API (Convex deployment)
    public static let defaultBaseURL = URL(string: "https://featurama.convex.site")!

    /// Default timeout interval (30 seconds)
    public static let defaultTimeoutInterval: TimeInterval = 30

    /// Creates a new configuration
    public init(
        apiKey: String,
        baseURL: URL = Configuration.defaultBaseURL,
        timeoutInterval: TimeInterval = Configuration.defaultTimeoutInterval,
        appVersion: String? = nil,
        appBuild: String? = nil
    ) throws {
        guard apiKey.hasPrefix(Configuration.apiKeyPrefix) else {
            throw FeaturamaSdkError.invalidApiKey
        }
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.timeoutInterval = timeoutInterval
        self.appVersion = appVersion
        self.appBuild = appBuild
    }
}
