import Foundation

/// Status of a feature request
public enum FeatureRequestStatus: String, Codable, Sendable, CaseIterable {
    case requested = "Requested"
    case roadmap = "Roadmap"
    case inProgress = "InProgress"
    case done = "Done"
    case declined = "Declined"
}

extension FeatureRequestStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .requested: return "Requested"
        case .roadmap: return "Roadmap"
        case .inProgress: return "In Progress"
        case .done: return "Done"
        case .declined: return "Declined"
        }
    }
}
