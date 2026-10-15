import Foundation

/// Decides when the board shows the shipped-request review card.
enum ShippedReview {
    struct Shipped: Equatable {
        let request: FeatureRequest
        let isOwn: Bool
    }

    private struct State: Codable {
        /// Done request IDs this device has already seen on the board.
        var knownDoneIds: [String]
        /// Requests that already triggered the card or the callback.
        var shownIds: [String]
        var lastShownAt: Date?
    }

    private static let storageKey = "featurama_shipped_review"
    private static let minInterval: TimeInterval = 90 * 24 * 60 * 60
    private static let maxStoredIds = 1000
    private static let pageSize = 100
    private static let maxPages = 3

    /// App Store review link for Apple platforms with an App Store. Nil hides the card.
    static func storeURL(_ links: ProjectConfig.ReviewLinks?) -> URL? {
        #if os(iOS) || os(macOS) || os(visionOS)
        guard let value = links?.appStoreUrl,
              var components = URLComponents(string: value),
              components.scheme?.lowercased() == "https",
              components.host?.lowercased() == "apps.apple.com"
        else { return nil }
        var items = components.percentEncodedQueryItems ?? []
        if !items.contains(where: { $0.name == "action" && $0.value == "write-review" }) {
            items.append(URLQueryItem(name: "action", value: "write-review"))
        }
        components.percentEncodedQueryItems = items
        return components.url
        #else
        return nil
        #endif
    }

    /// Compares the Done list with the previous board visit and returns at most one request
    /// this device submitted or voted for. The first visit only records a baseline.
    /// With `canNotify` false nothing is marked as shown, so the 90-day limit is not used up.
    static func find(voterId: String, canNotify: Bool, now: Date = Date()) async throws -> Shipped? {
        var done: [FeatureRequest] = []
        for page in 1...maxPages {
            let response = try await FeaturamaSdk.getRequests(
                page: page, pageSize: pageSize, filter: "done", submitterIdentifier: voterId
            )
            done += response.items
            if !response.hasNextPage || response.items.isEmpty { break }
        }
        done = done.filter { $0.status == .done }
        let doneIds = done.map(\.id)

        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let previous = try? JSONDecoder().decode(State.self, from: data)
        else {
            save(State(knownDoneIds: merge([], doneIds), shownIds: [], lastShownAt: nil))
            return nil
        }

        let known = Set(previous.knownDoneIds)
        let shown = Set(previous.shownIds)
        let candidates = done
            .filter { !known.contains($0.id) && !shown.contains($0.id) }
            .map { Shipped(request: $0, isOwn: !voterId.isEmpty && $0.submitterIdentifier == voterId) }
            .filter { $0.isOwn || $0.request.hasVoted }
        let allowed = canNotify && (previous.lastShownAt.map { now.timeIntervalSince($0) >= minInterval } ?? true)
        let shipped = allowed ? (candidates.first(where: \.isOwn) ?? candidates.first) : nil

        save(State(
            knownDoneIds: merge(previous.knownDoneIds, doneIds),
            shownIds: shipped.map { merge(previous.shownIds, [$0.request.id]) } ?? previous.shownIds,
            lastShownAt: shipped == nil ? previous.lastShownAt : now
        ))
        return shipped
    }

    private static func merge(_ previous: [String], _ added: [String]) -> [String] {
        var seen = Set<String>()
        let merged = (previous + added).filter { seen.insert($0).inserted }
        return Array(merged.suffix(maxStoredIds))
    }

    private static func save(_ state: State) {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
