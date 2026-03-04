import Foundation

/// Represents a feature request in the Featurama system
public struct FeatureRequest: Codable, Identifiable, Sendable, Equatable {
    /// Unique identifier of the feature request
    public let id: String

    /// ID of the project this request belongs to
    public let projectId: String

    /// Title of the feature request
    public let title: String

    /// Detailed description of the feature request
    public let description: String

    /// Current status of the feature request
    public let status: FeatureRequestStatus

    /// Source from which this request was created
    public let source: FeatureRequestSource

    /// Number of votes this request has received
    public let voteCount: Int

    /// Identifier of the user who submitted the request
    public let submitterIdentifier: String

    /// Email of the submitter (if provided)
    public let submitterEmail: String?

    /// Number of comments on this request
    public let commentCount: Int

    /// Date when the request was created
    public let createdAt: Date

    /// Device information attached at creation
    public let deviceInfo: DeviceInfoData?

    /// Whether the request has been approved by a developer
    public let isApproved: Bool

    /// Whether the current user has voted on this request
    public let hasVoted: Bool

    public init(
        id: String,
        projectId: String,
        title: String,
        description: String,
        status: FeatureRequestStatus,
        source: FeatureRequestSource,
        voteCount: Int,
        submitterIdentifier: String,
        submitterEmail: String? = nil,
        commentCount: Int = 0,
        createdAt: Date,
        deviceInfo: DeviceInfoData? = nil,
        isApproved: Bool = true,
        hasVoted: Bool = false
    ) {
        self.id = id
        self.projectId = projectId
        self.title = title
        self.description = description
        self.status = status
        self.source = source
        self.voteCount = voteCount
        self.submitterIdentifier = submitterIdentifier
        self.submitterEmail = submitterEmail
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.deviceInfo = deviceInfo
        self.isApproved = isApproved
        self.hasVoted = hasVoted
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        projectId = try container.decode(String.self, forKey: .projectId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        status = try container.decode(FeatureRequestStatus.self, forKey: .status)
        source = try container.decode(FeatureRequestSource.self, forKey: .source)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
        submitterIdentifier = try container.decode(String.self, forKey: .submitterIdentifier)
        submitterEmail = try container.decodeIfPresent(String.self, forKey: .submitterEmail)
        commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount) ?? 0
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        deviceInfo = try container.decodeIfPresent(DeviceInfoData.self, forKey: .deviceInfo)
        isApproved = try container.decodeIfPresent(Bool.self, forKey: .isApproved) ?? true
        hasVoted = try container.decodeIfPresent(Bool.self, forKey: .hasVoted) ?? false
    }
}
