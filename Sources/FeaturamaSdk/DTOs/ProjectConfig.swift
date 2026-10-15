import Foundation

/// Project configuration returned by the API
public struct ProjectConfig: Codable, Sendable {
    /// Branding settings
    public let branding: Branding

    /// Email collection setting
    public let emailCollection: EmailCollection

    /// Optional store links. Older servers omit this field.
    public let reviewLinks: ReviewLinks?

    public struct ReviewLinks: Codable, Sendable {
        public let appStoreUrl: String?
        public let playStoreUrl: String?

        public init(appStoreUrl: String? = nil, playStoreUrl: String? = nil) {
            self.appStoreUrl = appStoreUrl
            self.playStoreUrl = playStoreUrl
        }
    }

    /// Branding configuration
    public struct Branding: Codable, Sendable {
        /// Whether to show "Powered by Featurama" branding
        public let showBranding: Bool
    }

    /// Email collection mode
    public enum EmailCollection: String, Codable, Sendable {
        case none
        case optional
        case required
    }
}
