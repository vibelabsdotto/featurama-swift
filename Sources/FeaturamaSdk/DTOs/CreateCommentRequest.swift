import Foundation

/// DTO for adding a comment to a feature request
public struct CreateCommentRequest: Encodable, Sendable {
    /// Content of the comment
    public let content: String

    /// Identifier of the comment author
    public let authorIdentifier: String

    /// Optional display name of the comment author
    public let authorName: String?

    public init(content: String, authorIdentifier: String, authorName: String? = nil) {
        self.content = content
        self.authorIdentifier = authorIdentifier
        self.authorName = authorName
    }
}
