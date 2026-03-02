import SwiftUI

struct RequestCardView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    let request: FeatureRequest
    let isVoting: Bool
    let onToggleVote: () -> Void
    let onPress: () -> Void

    var body: some View {
        Button(action: onPress) {
            HStack(alignment: .top, spacing: 12) {
                // Vote button
                Button(action: onToggleVote) {
                    VStack(spacing: 2) {
                        if isVoting {
                            ProgressView()
                                .tint(theme.accent)
                        } else {
                            ChevronUpIconShape()
                                .stroke(theme.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                                .frame(width: 20, height: 20)
                            Text("\(request.voteCount)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(theme.accent)
                        }
                    }
                    .frame(minWidth: 48)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(RoundedRectangle(cornerRadius: 8).fill(theme.accentLight))
                }
                .buttonStyle(.plain)
                .disabled(isVoting || !request.isApproved)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(request.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.text)
                            .lineLimit(1)

                        if !request.isApproved {
                            Text(strings.pendingReview)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(theme.warningText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(theme.warningLight)
                                )
                        } else if request.status == .roadmap {
                            Text(strings.badgePlanned)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(theme.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(theme.accentLight)
                                )
                        }
                    }

                    if !request.description.isEmpty {
                        Text(request.description)
                            .font(.system(size: 13))
                            .foregroundColor(theme.textSecondary)
                            .lineLimit(2)
                            .lineSpacing(2)
                    }

                    if request.commentCount > 0 {
                        HStack(spacing: 4) {
                            ChatBubbleIconShape()
                                .stroke(theme.textSecondary, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                                .frame(width: 14, height: 14)
                            Text(strings.commentsCount.replacingOccurrences(of: "{count}", with: String(request.commentCount)))
                                .font(.system(size: 12))
                                .foregroundColor(theme.textSecondary)
                        }
                        .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
