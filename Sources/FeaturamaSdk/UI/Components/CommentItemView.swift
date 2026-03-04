import SwiftUI

struct CommentItemView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    let comment: Comment
    let isVoting: Bool
    let onToggleVote: (String) -> Void

    private var displayName: String {
        comment.authorName ?? String(comment.authorIdentifier.prefix(8))
    }

    private var isDeveloper: Bool {
        comment.authorRole == .developer
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header: author + developer badge + time
            HStack(spacing: 6) {
                Text(displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(theme.text)

                if isDeveloper {
                    Text(strings.developerBadge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(theme.accentForeground)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(RoundedRectangle(cornerRadius: 4).fill(theme.accent))
                }

                Spacer()

                Text(RelativeTimeFormatter.format(comment.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(theme.textSecondary)
            }

            // Content
            Text(comment.content)
                .font(.system(size: 14))
                .foregroundColor(theme.text)
                .lineSpacing(3)

            // Vote row
            Button(action: { onToggleVote(comment.id) }) {
                HStack(spacing: 4) {
                    if isVoting {
                        ProgressView()
                            .tint(theme.accent)
                    } else {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(theme.textSecondary)
                        Text("\(comment.voteCount)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(isVoting)
            .padding(.top, 4)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.border)
                .frame(height: 0.5)
        }
    }
}
