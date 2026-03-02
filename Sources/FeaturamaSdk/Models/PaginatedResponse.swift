import Foundation

/// A paginated response containing items and pagination metadata
public struct PaginatedResponse<T: Codable & Sendable>: Codable, Sendable {
    /// The items in the current page
    public let items: [T]

    /// Total number of items across all pages
    public let totalCount: Int

    /// Current page number (1-indexed)
    public let page: Int

    /// Number of items per page
    public let pageSize: Int

    /// Total number of pages
    public var totalPages: Int {
        guard pageSize > 0 else { return 0 }
        return (totalCount + pageSize - 1) / pageSize
    }

    /// Whether there is a next page
    public var hasNextPage: Bool {
        page < totalPages
    }

    /// Whether there is a previous page
    public var hasPreviousPage: Bool {
        page > 1
    }

    public init(items: [T], totalCount: Int, page: Int, pageSize: Int) {
        self.items = items
        self.totalCount = totalCount
        self.page = page
        self.pageSize = pageSize
    }
}
