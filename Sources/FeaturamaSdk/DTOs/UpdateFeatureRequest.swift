import Foundation

/// DTO for updating an existing feature request
public struct UpdateFeatureRequest: Encodable, Sendable {
    /// Updated title of the feature request
    public let title: String

    /// Updated description of the feature request
    public let description: String

    /// Identifier of the user who originally submitted the request (required for authorization)
    public let submitterIdentifier: String

    public init(title: String, description: String, submitterIdentifier: String) {
        self.title = title
        self.description = description
        self.submitterIdentifier = submitterIdentifier
    }
}
