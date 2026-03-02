import Foundation

/// DTO for creating a new feature request
public struct CreateFeatureRequest: Encodable, Sendable {
    /// Title of the feature request
    public let title: String

    /// Detailed description of the feature request
    public let description: String

    /// Identifier of the user submitting the request
    public let submitterIdentifier: String

    /// Optional email of the submitter
    public let email: String?

    /// Device information (auto-populated by the SDK)
    public var deviceInfo: DeviceInfoData?

    public init(title: String, description: String, submitterIdentifier: String, email: String? = nil) {
        self.title = title
        self.description = description
        self.submitterIdentifier = submitterIdentifier
        self.email = email
        self.deviceInfo = nil
    }
}
