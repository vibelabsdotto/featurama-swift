import XCTest
@testable import FeaturamaSdk

final class FeaturamaSdkTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        FeaturamaSdk.reset()
    }

    // MARK: - Configuration Tests

    func testValidApiKey() throws {
        let config = try Configuration(apiKey: "fm_live_test_key_123456")
        XCTAssertEqual(config.apiKey, "fm_live_test_key_123456")
    }

    func testInvalidApiKeyPrefix() {
        XCTAssertThrowsError(try Configuration(apiKey: "invalid_key")) { error in
            guard case FeaturamaSdkError.invalidApiKey = error else {
                XCTFail("Expected invalidApiKey error, got \(error)")
                return
            }
        }
    }

    func testInvalidApiKeyEmpty() {
        XCTAssertThrowsError(try Configuration(apiKey: "")) { error in
            guard case FeaturamaSdkError.invalidApiKey = error else {
                XCTFail("Expected invalidApiKey error, got \(error)")
                return
            }
        }
    }

    func testCustomBaseURL() throws {
        let customURL = URL(string: "https://custom.api.com")!
        let config = try Configuration(apiKey: "fm_live_abc123", baseURL: customURL)
        XCTAssertEqual(config.baseURL, customURL)
    }

    func testCustomTimeout() throws {
        let config = try Configuration(apiKey: "fm_live_abc123", timeoutInterval: 60)
        XCTAssertEqual(config.timeoutInterval, 60)
    }

    func testDefaultValues() throws {
        let config = try Configuration(apiKey: "fm_live_abc123")
        XCTAssertEqual(config.baseURL, Configuration.defaultBaseURL)
        XCTAssertEqual(config.timeoutInterval, Configuration.defaultTimeoutInterval)
    }

    // MARK: - SDK Configuration Tests

    func testSdkConfigure() throws {
        XCTAssertFalse(FeaturamaSdk.isConfigured)
        try FeaturamaSdk.configure(apiKey: "fm_live_abc123")
        XCTAssertTrue(FeaturamaSdk.isConfigured)
        XCTAssertNotNil(FeaturamaSdk.shared)
    }

    func testSdkConfigureWithInvalidKey() {
        XCTAssertThrowsError(try FeaturamaSdk.configure(apiKey: "invalid")) { error in
            guard case FeaturamaSdkError.invalidApiKey = error else {
                XCTFail("Expected invalidApiKey error")
                return
            }
        }
        XCTAssertFalse(FeaturamaSdk.isConfigured)
    }

    func testSdkReset() throws {
        try FeaturamaSdk.configure(apiKey: "fm_live_abc123")
        XCTAssertTrue(FeaturamaSdk.isConfigured)
        FeaturamaSdk.reset()
        XCTAssertFalse(FeaturamaSdk.isConfigured)
        XCTAssertNil(FeaturamaSdk.shared)
    }

    // MARK: - Model Encoding/Decoding Tests

    func testFeatureRequestStatusCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for status in FeatureRequestStatus.allCases {
            let data = try encoder.encode(status)
            let decoded = try decoder.decode(FeatureRequestStatus.self, from: data)
            XCTAssertEqual(status, decoded)
        }
    }

    func testFeatureRequestSourceCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let sources: [FeatureRequestSource] = [.sdk, .dashboard]
        for source in sources {
            let data = try encoder.encode(source)
            let decoded = try decoder.decode(FeatureRequestSource.self, from: data)
            XCTAssertEqual(source, decoded)
        }
    }

    func testFeatureRequestDecoding() throws {
        let json = """
        {
            "id": "abc123",
            "projectId": "proj456",
            "title": "Test Feature",
            "description": "A test feature request",
            "status": "Requested",
            "source": "SDK",
            "voteCount": 5,
            "submitterIdentifier": "user123",
            "commentCount": 3,
            "createdAt": "2024-01-15T10:30:00Z",
            "isApproved": true
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = json.data(using: .utf8)!
        let request = try decoder.decode(FeatureRequest.self, from: data)

        XCTAssertEqual(request.id, "abc123")
        XCTAssertEqual(request.projectId, "proj456")
        XCTAssertEqual(request.title, "Test Feature")
        XCTAssertEqual(request.description, "A test feature request")
        XCTAssertEqual(request.status, .requested)
        XCTAssertEqual(request.source, .sdk)
        XCTAssertEqual(request.voteCount, 5)
        XCTAssertEqual(request.submitterIdentifier, "user123")
        XCTAssertEqual(request.commentCount, 3)
        XCTAssertTrue(request.isApproved)
    }

    func testFeatureRequestDecodingDefaults() throws {
        let json = """
        {
            "id": "abc123",
            "projectId": "proj456",
            "title": "Test",
            "description": "Desc",
            "status": "Requested",
            "source": "SDK",
            "voteCount": 0,
            "submitterIdentifier": "user1",
            "createdAt": "2024-01-15T10:30:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = json.data(using: .utf8)!
        let request = try decoder.decode(FeatureRequest.self, from: data)

        XCTAssertEqual(request.commentCount, 0)
        XCTAssertTrue(request.isApproved)
        XCTAssertNil(request.submitterEmail)
        XCTAssertNil(request.deviceInfo)
    }

    func testDateDecodingAcceptsBackendMilliseconds() throws {
        // The backend always serializes createdAt via JS toISOString(),
        // which includes fractional seconds. .iso8601 rejects this shape
        // on iOS <= 17 / macOS <= 14; the SDK's custom strategy must not.
        let json = """
        {
            "id": "abc123",
            "projectId": "proj456",
            "title": "Test",
            "description": "Desc",
            "status": "Requested",
            "source": "SDK",
            "voteCount": 0,
            "submitterIdentifier": "user1",
            "createdAt": "2024-01-15T10:30:00.123Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { try FeaturamaDateDecoding.decode($0) }

        let data = json.data(using: .utf8)!
        let request = try decoder.decode(FeatureRequest.self, from: data)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let expected = formatter.date(from: "2024-01-15T10:30:00.123Z")!
        XCTAssertEqual(request.createdAt.timeIntervalSince1970,
                       expected.timeIntervalSince1970,
                       accuracy: 0.001)
    }

    func testDateDecodingAcceptsWholeSeconds() throws {
        let json = """
        {
            "id": "abc123",
            "projectId": "proj456",
            "title": "Test",
            "description": "Desc",
            "status": "Requested",
            "source": "SDK",
            "voteCount": 0,
            "submitterIdentifier": "user1",
            "createdAt": "2024-01-15T10:30:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { try FeaturamaDateDecoding.decode($0) }

        let data = json.data(using: .utf8)!
        let request = try decoder.decode(FeatureRequest.self, from: data)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let expected = formatter.date(from: "2024-01-15T10:30:00Z")!
        XCTAssertEqual(request.createdAt.timeIntervalSince1970,
                       expected.timeIntervalSince1970,
                       accuracy: 0.001)
    }

    func testDateDecodingRejectsMalformedTimestamp() throws {
        let json = """
        {
            "id": "abc123",
            "projectId": "proj456",
            "title": "Test",
            "description": "Desc",
            "status": "Requested",
            "source": "SDK",
            "voteCount": 0,
            "submitterIdentifier": "user1",
            "createdAt": "not-a-date"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { try FeaturamaDateDecoding.decode($0) }

        let data = json.data(using: .utf8)!
        XCTAssertThrowsError(try decoder.decode(FeatureRequest.self, from: data))
    }

    func testPaginatedResponseDecoding() throws {
        let json = """
        {
            "items": [
                {
                    "id": "abc123",
                    "projectId": "proj456",
                    "title": "Test Feature",
                    "description": "A test feature request",
                    "status": "Requested",
                    "source": "SDK",
                    "voteCount": 5,
                    "submitterIdentifier": "user123",
                    "createdAt": "2024-01-15T10:30:00Z"
                }
            ],
            "totalCount": 1,
            "page": 1,
            "pageSize": 20
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = json.data(using: .utf8)!
        let response = try decoder.decode(PaginatedResponse<FeatureRequest>.self, from: data)

        XCTAssertEqual(response.items.count, 1)
        XCTAssertEqual(response.totalCount, 1)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.pageSize, 20)
        XCTAssertEqual(response.totalPages, 1)
        XCTAssertFalse(response.hasNextPage)
        XCTAssertFalse(response.hasPreviousPage)
    }

    func testPaginatedResponsePagination() {
        let response = PaginatedResponse<FeatureRequest>(
            items: [],
            totalCount: 45,
            page: 2,
            pageSize: 20
        )

        XCTAssertEqual(response.totalPages, 3)
        XCTAssertTrue(response.hasNextPage)
        XCTAssertTrue(response.hasPreviousPage)
    }

    // MARK: - DTO Encoding Tests

    func testCreateFeatureRequestEncoding() throws {
        let encoder = JSONEncoder()

        let createRequest = CreateFeatureRequest(
            title: "New Feature",
            description: "Feature description",
            submitterIdentifier: "user456"
        )

        let data = try encoder.encode(createRequest)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["title"] as? String, "New Feature")
        XCTAssertEqual(json["description"] as? String, "Feature description")
        XCTAssertEqual(json["submitterIdentifier"] as? String, "user456")
    }

    func testCreateFeatureRequestWithEmail() throws {
        let encoder = JSONEncoder()

        let createRequest = CreateFeatureRequest(
            title: "New Feature",
            description: "Description",
            submitterIdentifier: "user456",
            email: "test@example.com"
        )

        let data = try encoder.encode(createRequest)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["email"] as? String, "test@example.com")
    }

    func testUpdateFeatureRequestEncoding() throws {
        let encoder = JSONEncoder()

        let updateRequest = UpdateFeatureRequest(
            title: "Updated Feature",
            description: "Updated description",
            submitterIdentifier: "user123"
        )

        let data = try encoder.encode(updateRequest)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["title"] as? String, "Updated Feature")
        XCTAssertEqual(json["description"] as? String, "Updated description")
        XCTAssertEqual(json["submitterIdentifier"] as? String, "user123")
    }

    func testVoteRequestEncoding() throws {
        let encoder = JSONEncoder()

        let voteRequest = VoteRequest(voterIdentifier: "voter789")

        let data = try encoder.encode(voteRequest)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["voterIdentifier"] as? String, "voter789")
    }

    func testCreateCommentRequestEncoding() throws {
        let encoder = JSONEncoder()

        let commentRequest = CreateCommentRequest(
            content: "Great idea!",
            authorIdentifier: "user123",
            authorName: "Max"
        )

        let data = try encoder.encode(commentRequest)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["content"] as? String, "Great idea!")
        XCTAssertEqual(json["authorIdentifier"] as? String, "user123")
        XCTAssertEqual(json["authorName"] as? String, "Max")
    }

    // MARK: - Comment Decoding Tests

    func testCommentDecoding() throws {
        let json = """
        {
            "id": "comment1",
            "featureRequestId": "req1",
            "content": "Great idea!",
            "authorIdentifier": "user1",
            "authorName": "Max",
            "authorRole": "user",
            "voteCount": 3,
            "createdAt": "2024-06-01T12:00:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = json.data(using: .utf8)!
        let comment = try decoder.decode(Comment.self, from: data)

        XCTAssertEqual(comment.id, "comment1")
        XCTAssertEqual(comment.content, "Great idea!")
        XCTAssertEqual(comment.authorRole, .user)
        XCTAssertEqual(comment.voteCount, 3)
    }

    func testCommentDeveloperRole() throws {
        let json = """
        {
            "id": "comment2",
            "featureRequestId": "req1",
            "content": "We're on it!",
            "authorIdentifier": "dev1",
            "authorRole": "developer",
            "voteCount": 0,
            "createdAt": "2024-06-01T12:00:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = json.data(using: .utf8)!
        let comment = try decoder.decode(Comment.self, from: data)

        XCTAssertEqual(comment.authorRole, .developer)
        XCTAssertNil(comment.authorName)
    }

    // MARK: - Error Tests

    func testErrorDescriptions() {
        let errors: [FeaturamaSdkError] = [
            .invalidApiKey,
            .invalidURL,
            .httpError(statusCode: 500, message: "Internal Server Error"),
            .httpError(statusCode: 400, message: nil),
            .unauthorized,
            .notFound,
            .conflict(message: "Already voted")
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }

    // MARK: - Status Description Tests

    func testFeatureRequestStatusDescriptions() {
        XCTAssertEqual(FeatureRequestStatus.requested.description, "Requested")
        XCTAssertEqual(FeatureRequestStatus.roadmap.description, "Roadmap")
        XCTAssertEqual(FeatureRequestStatus.inProgress.description, "In Progress")
        XCTAssertEqual(FeatureRequestStatus.done.description, "Done")
        XCTAssertEqual(FeatureRequestStatus.declined.description, "Declined")
    }

    func testFeatureRequestSourceDescriptions() {
        XCTAssertEqual(FeatureRequestSource.sdk.description, "SDK")
        XCTAssertEqual(FeatureRequestSource.dashboard.description, "Dashboard")
    }

    // MARK: - Status Raw Values

    func testFeatureRequestStatusRawValues() {
        XCTAssertEqual(FeatureRequestStatus.requested.rawValue, "Requested")
        XCTAssertEqual(FeatureRequestStatus.inProgress.rawValue, "InProgress")
    }

    func testFeatureRequestSourceRawValues() {
        XCTAssertEqual(FeatureRequestSource.sdk.rawValue, "SDK")
        XCTAssertEqual(FeatureRequestSource.dashboard.rawValue, "Dashboard")
    }
}
