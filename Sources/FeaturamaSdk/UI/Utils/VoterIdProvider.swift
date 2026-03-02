import Foundation

enum VoterIdProvider {
    private static let key = "featurama_voter_id"

    static func getOrCreate() -> String {
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let id = UUID().uuidString.lowercased()
        UserDefaults.standard.set(id, forKey: key)
        return id
    }
}
