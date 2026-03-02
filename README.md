# Featurama Swift SDK

A native Swift SDK for the Featurama feature request management platform.

> Status: Coming soon for MVP. React Native / Expo is currently the production-ready SDK.

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/featurama-swift-sdk.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select your version rules

## Quick Start

### Configure the SDK

Configure the SDK once at app startup (e.g., in `AppDelegate` or `@main App`):

```swift
import FeaturamaSdk

// In your app initialization
do {
    try FeaturamaSdk.configure(apiKey: "fm_live_your_api_key_here")
} catch {
    print("Failed to configure Featurama SDK: \(error)")
}
```

### Basic Usage

```swift
import FeaturamaSdk

// Fetch feature requests
let response = try await FeaturamaSdk.getRequests(page: 1, pageSize: 20)
for request in response.items {
    print("\(request.title) - \(request.voteCount) votes")
}

// Create a new feature request
let newRequest = CreateFeatureRequest(
    title: "Dark Mode Support",
    description: "Please add a dark mode option for the app",
    submitterIdentifier: "user_123"
)
let created = try await FeaturamaSdk.createRequest(newRequest)

// Vote on a feature request
let voted = try await FeaturamaSdk.vote(
    requestId: created.id,
    voterIdentifier: "user_456"
)

// Remove a vote
let unvoted = try await FeaturamaSdk.removeVote(
    requestId: created.id,
    voterIdentifier: "user_456"
)
```

## Advanced Usage

### Using a Custom Client Instance

If you need multiple configurations or don't want to use the singleton:

```swift
let config = try Configuration(
    apiKey: "fm_live_your_api_key_here",
    baseURL: URL(string: "https://your-deployment.convex.site")!,
    timeoutInterval: 60
)
let client = FeaturamaSdkClient(configuration: config)

let response = try await client.getRequests()
```

### Custom Convex Deployment

Point the SDK to your own Convex deployment:

```swift
try FeaturamaSdk.configure(
    apiKey: "fm_live_your_api_key_here",
    baseURL: URL(string: "https://your-deployment.convex.site")!
)
```

## API Reference

### FeaturamaSdk

Static methods for the singleton pattern:

| Method | Description |
|--------|-------------|
| `configure(apiKey:baseURL:timeoutInterval:)` | Configure the SDK |
| `reset()` | Reset the SDK, clearing the shared client |
| `isConfigured` | Check if the SDK is configured |
| `getRequests(page:pageSize:)` | Fetch paginated feature requests |
| `createRequest(_:)` | Create a new feature request |
| `updateRequest(id:updateRequest:)` | Update an existing feature request |
| `vote(requestId:voterIdentifier:)` | Add a vote to a feature request |
| `removeVote(requestId:voterIdentifier:)` | Remove a vote from a feature request |

### FeaturamaSdkClient

Instance methods for direct client usage:

| Method | Description |
|--------|-------------|
| `getRequests(page:pageSize:)` | Fetch paginated feature requests |
| `createRequest(_:)` | Create a new feature request |
| `updateRequest(id:updateRequest:)` | Update an existing feature request |
| `vote(requestId:voterIdentifier:)` | Add a vote to a feature request |
| `removeVote(requestId:voterIdentifier:)` | Remove a vote from a feature request |

### Models

#### FeatureRequest

```swift
public struct FeatureRequest {
    let id: UUID
    let projectId: UUID
    let title: String
    let description: String
    let status: FeatureRequestStatus
    let source: FeatureRequestSource
    let voteCount: Int
    let submitterIdentifier: String
    let createdAt: Date
}
```

#### FeatureRequestStatus

```swift
public enum FeatureRequestStatus: Int {
    case requested = 0
    case roadmap = 1
    case inProgress = 2
    case done = 3
    case declined = 4
}
```

#### FeatureRequestSource

```swift
public enum FeatureRequestSource: Int {
    case sdk = 0
    case dashboard = 1
}
```

### DTOs

#### CreateFeatureRequest

```swift
public struct CreateFeatureRequest {
    let title: String
    let description: String
    let submitterIdentifier: String
}
```

#### UpdateFeatureRequest

```swift
public struct UpdateFeatureRequest {
    let title: String
    let description: String
    let submitterIdentifier: String
}
```

#### VoteRequest

```swift
public struct VoteRequest {
    let voterIdentifier: String
}
```

## Error Handling

The SDK throws `FeaturamaSdkError` for all error cases:

```swift
do {
    let response = try await FeaturamaSdk.getRequests()
} catch FeaturamaSdkError.unauthorized {
    print("Invalid API key")
} catch FeaturamaSdkError.notFound {
    print("Resource not found")
} catch FeaturamaSdkError.conflict(let message) {
    print("Conflict: \(message)")  // e.g., already voted
} catch FeaturamaSdkError.httpError(let code, let message) {
    print("HTTP \(code): \(message ?? "Unknown error")")
} catch {
    print("Error: \(error)")
}
```

### Error Types

| Error | Description |
|-------|-------------|
| `invalidApiKey` | API key doesn't start with `fm_live_` |
| `invalidURL` | Failed to construct URL |
| `httpError(statusCode:message:)` | HTTP error response |
| `decodingError(Error)` | Failed to decode response |
| `networkError(Error)` | Network connectivity error |
| `unauthorized` | 401 - Invalid or missing API key |
| `notFound` | 404 - Resource not found |
| `conflict(message:)` | 409 - Conflict (e.g., duplicate vote) |

## Thread Safety

The SDK is fully thread-safe and uses Swift's `Sendable` protocol. All methods are `async` and can be called from any thread or actor context.

## License

MIT License - see LICENSE file for details.
