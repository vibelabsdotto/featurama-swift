import Foundation

/// ISO8601 date decoding that accepts timestamps both with and without
/// fractional seconds.
///
/// `JSONDecoder.dateDecodingStrategy = .iso8601` rejects timestamps with
/// fractional seconds on iOS <= 17, macOS <= 14, tvOS <= 17 and watchOS <= 10
/// (fractional-seconds support in the built-in strategy only arrived with the
/// 2024 OS releases). The Featurama backend serializes every timestamp via
/// JS `toISOString()`, which always emits milliseconds — so `.iso8601`
/// breaks decoding of every response on the SDK's own minimum deployment
/// targets. This custom strategy works everywhere Foundation does.
enum FeaturamaDateDecoding {
    /// The lock protects both formatters across concurrent client requests.
    private final class Formatters: @unchecked Sendable {
        let lock = NSLock()
        let fractionalSeconds: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter
        }()

        let wholeSeconds: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            return formatter
        }()
    }
    private static let formatters = Formatters()

    /// Decoder strategy closure: try fractional seconds first (the shape the
    /// backend always produces), then fall back to whole-second timestamps.
    static func decode(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)

        formatters.lock.lock()
        defer { formatters.lock.unlock() }
        if let date = formatters.fractionalSeconds.date(from: raw) {
            return date
        }
        if let date = formatters.wholeSeconds.date(from: raw) {
            return date
        }
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Expected ISO8601 date string, got \(raw)"
        )
    }
}
