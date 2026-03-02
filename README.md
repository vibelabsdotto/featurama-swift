# Featurama Swift SDK

Native Swift SDK for [Featurama](https://featurama.io) — in-app feature request management for iOS apps.

Includes a full API client and a drop-in SwiftUI view with voting, comments, filtering, and theming.

## Requirements

- iOS 16+ / macOS 13+ / tvOS 16+ / watchOS 9+
- Swift 5.9+
- Xcode 15+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/featurama-app/featurama-swift.git", from: "0.1.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → paste the repository URL.

## Quick Start

### 1. Configure

```swift
import FeaturamaSdk

@main
struct MyApp: App {
    init() {
        try? FeaturamaSdk.configure(apiKey: "fm_live_your_api_key_here")
    }

    var body: some Scene {
        WindowGroup {
            FeaturamaView(accentColor: .indigo)
        }
    }
}
```

That's it — `FeaturamaView` handles the full feature request UI out of the box.

### 2. Customize (optional)

```swift
FeaturamaView(
    accentColor: .mint,
    theme: FeaturamaThemeOverrides(
        background: Color(red: 0.94, green: 1.0, blue: 0.976),
        card: Color(red: 0.878, green: 1.0, blue: 0.953)
    ),
    onClose: { dismiss() }
)
```

## Pre-built UI

`FeaturamaView` is a full-screen SwiftUI component with:

- Feature request list with filtering (New, Trending, Top)
- Create request form with optional email collection
- Detail view with comments
- Voting and comment voting
- Dark/light mode support
- Customizable accent color and theme overrides
- Localization via `FeaturamaStrings`

### Theme Overrides

Override individual colors while keeping the rest auto-generated:

```swift
let theme = FeaturamaThemeOverrides(
    background: .black,
    card: Color(white: 0.1),
    accentForeground: .white
)

FeaturamaView(accentColor: .purple, theme: theme)
```

Available override properties: `background`, `card`, `secondary`, `text`, `textSecondary`, `accent`, `accentLight`, `accentForeground`, `border`, `borderAccent`, `gray100`, `warning`, `warningLight`, `warningText`.

### Localization

Pass custom strings for full localization:

```swift
let strings = FeaturamaStrings(
    featureRequests: "Funktionswünsche",
    newRequest: "Neuer Wunsch",
    vote: "Stimme"
    // ... see FeaturamaStrings for all keys
)

FeaturamaView(accentColor: .blue, strings: strings)
```

## API Client

Use the API client directly if you want to build your own UI:

```swift
// Fetch requests
let response = try await FeaturamaSdk.getRequests(page: 1, pageSize: 20, filter: "trending")

// Create a request
let request = CreateFeatureRequest(
    title: "Dark Mode",
    description: "Add dark mode support",
    submitterIdentifier: "user_123",
    email: "user@example.com"
)
let created = try await FeaturamaSdk.createRequest(request)

// Vote
let updated = try await FeaturamaSdk.toggleVote(
    requestId: created.id,
    voterIdentifier: "user_456"
)

// Comments
let comments = try await FeaturamaSdk.getComments(requestId: created.id)
let comment = try await FeaturamaSdk.addComment(
    requestId: created.id,
    input: CreateCommentRequest(content: "Great idea!", authorIdentifier: "user_456")
)
```

### All Methods

| Method | Description |
|--------|-------------|
| `configure(apiKey:baseURL:)` | Initialize the SDK |
| `getConfig()` | Fetch project configuration |
| `getRequests(page:pageSize:filter:submitterIdentifier:)` | List feature requests |
| `createRequest(_:)` | Create a feature request |
| `updateRequest(id:updateRequest:)` | Update a feature request |
| `vote(requestId:voterIdentifier:)` | Add a vote |
| `removeVote(requestId:voterIdentifier:)` | Remove a vote |
| `toggleVote(requestId:voterIdentifier:)` | Toggle a vote (handles conflicts) |
| `getComments(requestId:)` | Fetch comments |
| `addComment(requestId:input:)` | Add a comment |
| `voteComment(requestId:commentId:voterIdentifier:)` | Vote on a comment |
| `removeCommentVote(requestId:commentId:voterIdentifier:)` | Remove a comment vote |
| `toggleCommentVote(requestId:commentId:voterIdentifier:)` | Toggle a comment vote |

## Error Handling

```swift
do {
    let response = try await FeaturamaSdk.getRequests()
} catch FeaturamaSdkError.unauthorized {
    // Invalid API key
} catch FeaturamaSdkError.conflict(let message) {
    // Already voted
} catch FeaturamaSdkError.httpError(let code, let message) {
    // Other HTTP error
} catch {
    // Network or decoding error
}
```

## Thread Safety

All types conform to `Sendable`. All methods are `async`. Safe to call from any actor or thread.

## License

MIT — see [LICENSE](LICENSE) for details.
