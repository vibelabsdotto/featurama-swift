import Foundation

enum RelativeTimeFormatter {
    static func format(_ date: Date) -> String {
        let now = Date()
        let diff = now.timeIntervalSince(date)
        let minutes = Int(diff / 60)

        if minutes < 1 { return "just now" }
        if minutes < 60 { return "\(minutes)m ago" }

        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }

        let days = hours / 24
        if days < 30 { return "\(days)d ago" }

        let months = days / 30
        return "\(months)mo ago"
    }
}
