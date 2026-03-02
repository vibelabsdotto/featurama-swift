import Foundation

/// DTO for voting on a feature request
public struct VoteRequest: Encodable, Sendable {
    /// Identifier of the user casting the vote
    public let voterIdentifier: String

    public init(voterIdentifier: String) {
        self.voterIdentifier = voterIdentifier
    }
}
