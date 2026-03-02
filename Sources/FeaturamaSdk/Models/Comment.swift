import Foundation

/// Represents a comment on a feature request
public struct Comment: Codable, Identifiable, Sendable, Equatable {
    /// Unique identifier of the comment
    public let id: String

    /// ID of the feature request this comment belongs to
    public let featureRequestId: String

    /// Content of the comment
    public let content: String

    /// Identifier of the comment author
    public let authorIdentifier: String

    /// Display name of the comment author
    public let authorName: String?

    /// Role of the comment author
    public let authorRole: AuthorRole

    /// Number of votes this comment has received
    public let voteCount: Int

    /// Date when the comment was created
    public let createdAt: Date

    /// Role of a comment author
    public enum AuthorRole: String, Codable, Sendable {
        case user
        case developer
    }

    public init(
        id: String,
        featureRequestId: String,
        content: String,
        authorIdentifier: String,
        authorName: String? = nil,
        authorRole: AuthorRole,
        voteCount: Int,
        createdAt: Date
    ) {
        self.id = id
        self.featureRequestId = featureRequestId
        self.content = content
        self.authorIdentifier = authorIdentifier
        self.authorName = authorName
        self.authorRole = authorRole
        self.voteCount = voteCount
        self.createdAt = createdAt
    }
}
