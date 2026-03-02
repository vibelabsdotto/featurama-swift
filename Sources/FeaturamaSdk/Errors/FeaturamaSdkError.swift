import Foundation

/// Errors that can occur when using the Featurama SDK
public enum FeaturamaSdkError: Error, Sendable {
    /// The API key is invalid (must start with "fm_live_")
    case invalidApiKey

    /// The URL could not be constructed
    case invalidURL

    /// An HTTP error occurred
    case httpError(statusCode: Int, message: String?)

    /// Failed to decode the response
    case decodingError(Error)

    /// A network error occurred
    case networkError(Error)

    /// The request was unauthorized (401)
    case unauthorized

    /// The requested resource was not found (404)
    case notFound

    /// A conflict occurred, typically when voting twice (409)
    case conflict(message: String)
}

extension FeaturamaSdkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidApiKey:
            return "Invalid API key. The API key must start with 'fm_live_'."
        case .invalidURL:
            return "Failed to construct a valid URL."
        case .httpError(let statusCode, let message):
            if let message = message {
                return "HTTP error \(statusCode): \(message)"
            }
            return "HTTP error \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized. Please check your API key."
        case .notFound:
            return "The requested resource was not found."
        case .conflict(let message):
            return "Conflict: \(message)"
        }
    }
}

// Make the wrapped errors Sendable-compatible
extension FeaturamaSdkError {
    /// Creates a decoding error from a DecodingError
    static func fromDecodingError(_ error: DecodingError) -> FeaturamaSdkError {
        .decodingError(error)
    }

    /// Creates a network error from any Error
    static func fromNetworkError(_ error: any Error) -> FeaturamaSdkError {
        .networkError(error)
    }
}
