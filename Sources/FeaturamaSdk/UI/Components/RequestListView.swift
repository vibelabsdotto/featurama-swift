import SwiftUI

struct FeaturamaRequestListView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    let items: [FeatureRequest]?
    let isLoading: Bool
    let error: String?
    let votingIds: Set<String>
    let onToggleVote: (String) -> Void
    let onRequestPress: (FeatureRequest) -> Void
    let onRefresh: () async -> Void

    var body: some View {
        if isLoading && items == nil {
            Spacer()
            ProgressView()
                .tint(theme.accent)
            Spacer()
        } else if error != nil, items == nil {
            Spacer()
            VStack(spacing: 16) {
                Text(strings.error)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.textSecondary)
                Button {
                    Task { await onRefresh() }
                } label: {
                    Text(strings.retry)
                        .foregroundColor(theme.accentForeground)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(RoundedRectangle(cornerRadius: 8).fill(theme.accent))
                }
                .buttonStyle(.plain)
            }
            Spacer()
        } else if let items = items, items.isEmpty && !isLoading {
            Spacer()
            VStack(spacing: 8) {
                Text(strings.empty)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.textSecondary)
                Text(strings.emptyHint)
                    .font(.system(size: 14))
                    .foregroundColor(theme.textSecondary)
            }
            Spacer()
        } else if let items = items, !items.isEmpty {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(items) { request in
                        RequestCardView(
                            theme: theme,
                            strings: strings,
                            request: request,
                            isVoting: votingIds.contains(request.id),
                            onToggleVote: { onToggleVote(request.id) },
                            onPress: { onRequestPress(request) }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
            .refreshable {
                await onRefresh()
            }
        }
    }
}
