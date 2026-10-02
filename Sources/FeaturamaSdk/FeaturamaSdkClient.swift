import Foundation

/// Client for interacting with the Featurama API
///
/// Request and comment IDs must be nonempty URL-unreserved ASCII components
/// (`A-Z`, `a-z`, `0-9`, `-`, `.`, `_`, `~`), other than `.` or `..`.
/// Invalid IDs throw `FeaturamaSdkError.invalidURL` before sending a request.
public final class FeaturamaSdkClient: Sendable {
    let configuration: Configuration
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// Creates a new Featurama SDK client
    /// - Parameter configuration: The SDK configuration
    public init(configuration: Configuration) {
        self.configuration = configuration

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        sessionConfig.timeoutIntervalForResource = configuration.timeoutInterval
        self.session = URLSession(configuration: sessionConfig)

        self.encoder = JSONEncoder()

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .custom { try FeaturamaDateDecoding.decode($0) }
    }

    // MARK: - Config

    /// Fetches project configuration (branding, email settings)
    public func getConfig() async throws -> ProjectConfig {
        let url = configuration.baseURL.appendingPathComponent("/api/public/config")
        let request = buildRequest(url: url, method: "GET")
        return try await execute(request)
    }

    // MARK: - Feature Requests

    /// Fetches a paginated list of feature requests
    public func getRequests(page: Int = 1, pageSize: Int = 20, filter: String? = nil, submitterIdentifier: String? = nil) async throws -> PaginatedResponse<FeatureRequest> {
        var components = URLComponents(url: configuration.baseURL.appendingPathComponent("/api/public/requests"), resolvingAgainstBaseURL: true)
        var queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        if let filter = filter {
            queryItems.append(URLQueryItem(name: "filter", value: filter))
        }
        if let submitterIdentifier = submitterIdentifier {
            queryItems.append(URLQueryItem(name: "submitterIdentifier", value: submitterIdentifier))
        }
        components?.queryItems = queryItems

        // URLQueryItem leaves '+' literal; form-style query parsers read it as a space.
        let encodedQuery = components?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        components?.percentEncodedQuery = encodedQuery
        guard let url = components?.url else {
            throw FeaturamaSdkError.invalidURL
        }

        let request = buildRequest(url: url, method: "GET")
        return try await execute(request)
    }

    /// Creates a new feature request with automatic device info collection
    public func createRequest(_ createRequest: CreateFeatureRequest) async throws -> FeatureRequest {
        let url = configuration.baseURL.appendingPathComponent("/api/public/requests")
        var request = buildRequest(url: url, method: "POST")

        var input = createRequest
        var deviceInfo = await MainActor.run { createRequest.deviceInfo ?? DeviceInfoProvider.collect() }
        if let appVersion = configuration.appVersion {
            deviceInfo.appVersion = appVersion
        }
        if let appBuild = configuration.appBuild {
            deviceInfo.appBuild = appBuild
        }
        input.deviceInfo = deviceInfo

        request.httpBody = try encoder.encode(input)
        let created: FeatureRequest = try await execute(request)
        return created.withVotingState(true)
    }

    /// Updates an existing feature request
    public func updateRequest(id: String, updateRequest: UpdateFeatureRequest) async throws -> FeatureRequest {
        let url = try resourceURL("requests", id)
        var request = buildRequest(url: url, method: "PUT")
        request.httpBody = try encoder.encode(updateRequest)
        return try await execute(request)
    }

    // MARK: - Voting

    /// Adds a vote to a feature request
    public func vote(requestId: String, voterIdentifier: String) async throws -> FeatureRequest {
        let url = try resourceURL("requests", requestId, "vote")
        var request = buildRequest(url: url, method: "POST")
        let voteRequest = VoteRequest(voterIdentifier: voterIdentifier)
        request.httpBody = try encoder.encode(voteRequest)
        let updated: FeatureRequest = try await execute(request)
        return updated.withVotingState(true)
    }

    /// Removes a vote from a feature request
    public func removeVote(requestId: String, voterIdentifier: String) async throws -> FeatureRequest {
        var components = URLComponents(url: try resourceURL("requests", requestId, "vote"), resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "voterIdentifier", value: voterIdentifier)
        ]

        // URLQueryItem leaves '+' literal; form-style query parsers read it as a space.
        let encodedQuery = components?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        components?.percentEncodedQuery = encodedQuery
        guard let url = components?.url else {
            throw FeaturamaSdkError.invalidURL
        }

        let request = buildRequest(url: url, method: "DELETE")
        let updated: FeatureRequest = try await execute(request)
        return updated.withVotingState(false)
    }

    /// Toggles a vote on a feature request.
    /// If the user has not voted, adds a vote. If already voted (409 Conflict),
    /// removes the vote instead.
    public func toggleVote(requestId: String, voterIdentifier: String) async throws -> FeatureRequest {
        do {
            return try await vote(requestId: requestId, voterIdentifier: voterIdentifier)
        } catch {
            if case FeaturamaSdkError.conflict = error {
                return try await removeVote(requestId: requestId, voterIdentifier: voterIdentifier)
            }
            throw error
        }
    }

    // MARK: - Comments

    /// Fetches comments for a feature request
    public func getComments(requestId: String) async throws -> [Comment] {
        let url = try resourceURL("requests", requestId, "comments")
        let request = buildRequest(url: url, method: "GET")
        return try await execute(request)
    }

    /// Adds a comment to a feature request
    public func addComment(requestId: String, input: CreateCommentRequest) async throws -> Comment {
        let url = try resourceURL("requests", requestId, "comments")
        var request = buildRequest(url: url, method: "POST")
        request.httpBody = try encoder.encode(input)
        return try await execute(request)
    }

    /// Votes on a comment
    public func voteComment(requestId: String, commentId: String, voterIdentifier: String) async throws -> Comment {
        let url = try resourceURL("requests", requestId, "comments", commentId, "vote")
        var request = buildRequest(url: url, method: "POST")
        let body = VoteRequest(voterIdentifier: voterIdentifier)
        request.httpBody = try encoder.encode(body)
        return try await execute(request)
    }

    /// Removes a vote from a comment
    public func removeCommentVote(requestId: String, commentId: String, voterIdentifier: String) async throws -> Comment {
        var components = URLComponents(
            url: try resourceURL("requests", requestId, "comments", commentId, "vote"),
            resolvingAgainstBaseURL: true
        )
        components?.queryItems = [
            URLQueryItem(name: "voterIdentifier", value: voterIdentifier)
        ]
        // URLQueryItem leaves '+' literal; form-style query parsers read it as a space.
        let encodedQuery = components?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        components?.percentEncodedQuery = encodedQuery
        guard let url = components?.url else {
            throw FeaturamaSdkError.invalidURL
        }
        let request = buildRequest(url: url, method: "DELETE")
        return try await execute(request)
    }

    /// Toggles a vote on a comment (add if not voted, remove if already voted via 409)
    public func toggleCommentVote(requestId: String, commentId: String, voterIdentifier: String) async throws -> Comment {
        do {
            return try await voteComment(requestId: requestId, commentId: commentId, voterIdentifier: voterIdentifier)
        } catch {
            if case FeaturamaSdkError.conflict = error {
                return try await removeCommentVote(requestId: requestId, commentId: commentId, voterIdentifier: voterIdentifier)
            }
            throw error
        }
    }

    // MARK: - Private Helpers

    private func resourceURL(_ components: String...) throws -> URL {
        // appendingPathComponent does not escape embedded slashes. Reject them,
        // percent-encoded delimiters and dot segments rather than changing an ID
        // or relying on server/proxy decoding to keep it within one path segment.
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        var url = configuration.baseURL.appendingPathComponent("/api/public")
        for component in components {
            guard !component.isEmpty,
                  component != ".", component != "..",
                  component.rangeOfCharacter(from: allowed.inverted) == nil else {
                throw FeaturamaSdkError.invalidURL
            }
            url.appendPathComponent(component)
        }
        return url
    }

    private func buildRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(configuration.apiKey, forHTTPHeaderField: "X-Api-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw FeaturamaSdkError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw FeaturamaSdkError.networkError(URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200..<300:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw FeaturamaSdkError.decodingError(error)
            }
        case 401:
            throw FeaturamaSdkError.unauthorized
        case 404:
            throw FeaturamaSdkError.notFound
        case 409:
            let message = extractErrorMessage(from: data) ?? "Resource conflict"
            throw FeaturamaSdkError.conflict(message: message)
        default:
            let message = extractErrorMessage(from: data)
            throw FeaturamaSdkError.httpError(statusCode: httpResponse.statusCode, message: message)
        }
    }

    private func extractErrorMessage(from data: Data) -> String? {
        struct ErrorResponse: Decodable {
            let message: String?
            let error: String?
            let title: String?
        }

        if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
            return errorResponse.message ?? errorResponse.error ?? errorResponse.title
        }

        return String(data: data, encoding: .utf8)
    }
}
