import Foundation

/// Source from which a feature request was created
public enum FeatureRequestSource: String, Codable, Sendable {
    case sdk = "SDK"
    case dashboard = "Dashboard"
}

extension FeatureRequestSource: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sdk: return "SDK"
        case .dashboard: return "Dashboard"
        }
    }
}
