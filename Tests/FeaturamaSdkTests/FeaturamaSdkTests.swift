import XCTest
@testable import FeaturamaSdk

final class FeaturamaSdkTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        FeaturamaSdk.reset()
    }

    // MARK: - Configuration Tests

    func testValidApiKey() throws {
        let config = try Configuration(apiKey: "fm_live_abc123def456ghi789jkl")
        XCTAssertEqual(config.apiKey, "fm_live_abc123def456ghi789jkl")
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
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "project_id": "660e8400-e29b-41d4-a716-446655440001",
            "title": "Test Feature",
            "description": "A test feature request",
            "status": 0,
            "source": 0,
            "vote_count": 5,
            "submitter_identifier": "user123",
            "created_at": "2024-01-15T10:30:00Z"
        }
        """

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let data = json.data(using: .utf8)!
        let request = try decoder.decode(FeatureRequest.self, from: data)

        XCTAssertEqual(request.id, UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000"))
        XCTAssertEqual(request.projectId, UUID(uuidString: "660e8400-e29b-41d4-a716-446655440001"))
        XCTAssertEqual(request.title, "Test Feature")
        XCTAssertEqual(request.description, "A test feature request")
        XCTAssertEqual(request.status, .requested)
        XCTAssertEqual(request.source, .sdk)
        XCTAssertEqual(request.voteCount, 5)
        XCTAssertEqual(request.submitterIdentifier, "user123")
    }

    func testPaginatedResponseDecoding() throws {
        let json = """
        {
            "items": [
                {
                    "id": "550e8400-e29b-41d4-a716-446655440000",
                    "project_id": "660e8400-e29b-41d4-a716-446655440001",
                    "title": "Test Feature",
                    "description": "A test feature request",
                    "status": 0,
                    "source": 0,
                    "vote_count": 5,
                    "submitter_identifier": "user123",
                    "created_at": "2024-01-15T10:30:00Z"
                }
            ],
            "total_count": 1,
            "page": 1,
            "page_size": 20
        }
        """

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
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
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let createRequest = CreateFeatureRequest(
            title: "New Feature",
            description: "Feature description",
            submitterIdentifier: "user456"
        )

        let data = try encoder.encode(createRequest)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["title"] as? String, "New Feature")
        XCTAssertEqual(json["description"] as? String, "Feature description")
        XCTAssertEqual(json["submitter_identifier"] as? String, "user456")
    }

    func testUpdateFeatureRequestEncoding() throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let updateRequest = UpdateFeatureRequest(
            title: "Updated Feature",
            description: "Updated description",
            submitterIdentifier: "user123"
        )

        let data = try encoder.encode(updateRequest)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["title"] as? String, "Updated Feature")
        XCTAssertEqual(json["description"] as? String, "Updated description")
        XCTAssertEqual(json["submitter_identifier"] as? String, "user123")
    }

    func testVoteRequestEncoding() throws {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let voteRequest = VoteRequest(voterIdentifier: "voter789")

        let data = try encoder.encode(voteRequest)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["voter_identifier"] as? String, "voter789")
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
}
