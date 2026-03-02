import Foundation

/// Main entry point for the Featurama SDK
///
/// Use this class to configure and access the SDK:
///
/// ```swift
/// // Configure the SDK (typically in AppDelegate or App init)
/// try FeaturamaSdk.configure(
///     apiKey: "fm_live_your_api_key_here",
///     baseURL: URL(string: "https://your-deployment.convex.site")!
/// )
///
/// // Use the shared client
/// let requests = try await FeaturamaSdk.shared?.getRequests()
/// ```
///
/// Alternatively, create your own client instance:
///
/// ```swift
/// let config = try Configuration(apiKey: "fm_live_your_api_key_here")
/// let client = FeaturamaSdkClient(configuration: config)
/// let requests = try await client.getRequests()
/// ```
public final class FeaturamaSdk: @unchecked Sendable {
    /// The shared SDK client instance. Configure using `configure(apiKey:baseURL:timeoutInterval:)` before use.
    public private(set) static var shared: FeaturamaSdkClient?

    private static let lock = NSLock()

    private init() {}

    /// Configures the SDK with the provided settings
    public static func configure(
        apiKey: String,
        baseURL: URL = Configuration.defaultBaseURL,
        timeoutInterval: TimeInterval = Configuration.defaultTimeoutInterval,
        appVersion: String? = nil,
        appBuild: String? = nil
    ) throws {
        let configuration = try Configuration(
            apiKey: apiKey,
            baseURL: baseURL,
            timeoutInterval: timeoutInterval,
            appVersion: appVersion,
            appBuild: appBuild
        )
        configure(with: configuration)
    }

    /// Configures the SDK with a Configuration object
    /// - Parameter configuration: The SDK configuration
    public static func configure(with configuration: Configuration) {
        lock.lock()
        defer { lock.unlock() }
        shared = FeaturamaSdkClient(configuration: configuration)
    }

    /// Resets the SDK, clearing the shared client instance
    public static func reset() {
        lock.lock()
        defer { lock.unlock() }
        shared = nil
    }

    /// Returns whether the SDK has been configured
    public static var isConfigured: Bool {
        lock.lock()
        defer { lock.unlock() }
        return shared != nil
    }
}

// MARK: - Convenience Methods

extension FeaturamaSdk {

    // MARK: Config

    /// Fetches project configuration using the shared client
    public static func getConfig() async throws -> ProjectConfig {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.getConfig()
    }

    // MARK: Feature Requests

    /// Fetches a paginated list of feature requests using the shared client
    public static func getRequests(page: Int = 1, pageSize: Int = 20, filter: String? = nil, submitterIdentifier: String? = nil) async throws -> PaginatedResponse<FeatureRequest> {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.getRequests(page: page, pageSize: pageSize, filter: filter, submitterIdentifier: submitterIdentifier)
    }

    /// Creates a new feature request using the shared client
    public static func createRequest(_ createRequest: CreateFeatureRequest) async throws -> FeatureRequest {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.createRequest(createRequest)
    }

    /// Updates an existing feature request using the shared client
    public static func updateRequest(id: String, updateRequest: UpdateFeatureRequest) async throws -> FeatureRequest {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.updateRequest(id: id, updateRequest: updateRequest)
    }

    // MARK: Voting

    /// Adds a vote to a feature request using the shared client
    public static func vote(requestId: String, voterIdentifier: String) async throws -> FeatureRequest {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.vote(requestId: requestId, voterIdentifier: voterIdentifier)
    }

    /// Removes a vote from a feature request using the shared client
    public static func removeVote(requestId: String, voterIdentifier: String) async throws -> FeatureRequest {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.removeVote(requestId: requestId, voterIdentifier: voterIdentifier)
    }

    /// Toggles a vote using the shared client
    public static func toggleVote(requestId: String, voterIdentifier: String) async throws -> FeatureRequest {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.toggleVote(requestId: requestId, voterIdentifier: voterIdentifier)
    }

    // MARK: Comments

    /// Fetches comments for a feature request using the shared client
    public static func getComments(requestId: String) async throws -> [Comment] {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.getComments(requestId: requestId)
    }

    /// Adds a comment to a feature request using the shared client
    public static func addComment(requestId: String, input: CreateCommentRequest) async throws -> Comment {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.addComment(requestId: requestId, input: input)
    }

    /// Votes on a comment using the shared client
    public static func voteComment(requestId: String, commentId: String, voterIdentifier: String) async throws -> Comment {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.voteComment(requestId: requestId, commentId: commentId, voterIdentifier: voterIdentifier)
    }

    /// Removes a vote from a comment using the shared client
    public static func removeCommentVote(requestId: String, commentId: String, voterIdentifier: String) async throws -> Comment {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.removeCommentVote(requestId: requestId, commentId: commentId, voterIdentifier: voterIdentifier)
    }

    /// Toggles a vote on a comment using the shared client
    public static func toggleCommentVote(requestId: String, commentId: String, voterIdentifier: String) async throws -> Comment {
        guard let client = shared else { throw FeaturamaSdkError.invalidApiKey }
        return try await client.toggleCommentVote(requestId: requestId, commentId: commentId, voterIdentifier: voterIdentifier)
    }
}
