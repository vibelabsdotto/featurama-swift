import SwiftUI

struct RequestCardView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    let request: FeatureRequest
    let isVoting: Bool
    let onToggleVote: () -> Void
    let onPress: () -> Void

    private var voteColor: Color {
        request.hasVoted ? theme.accent : theme.textSecondary
    }

    private var voteBg: Color {
        request.hasVoted ? theme.accentLight : theme.gray100
    }

    var body: some View {
        Button(action: onPress) {
            HStack(alignment: .top, spacing: 12) {
                // Vote button
                Button(action: onToggleVote) {
                    VStack(spacing: 2) {
                        if isVoting {
                            ProgressView()
                                .tint(voteColor)
                        } else {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(voteColor)
                            Text("\(request.voteCount)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(voteColor)
                        }
                    }
                    .frame(minWidth: 48)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(RoundedRectangle(cornerRadius: 8).fill(voteBg))
                }
                .buttonStyle(.plain)
                .disabled(isVoting || !request.isApproved)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.text)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 28)

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

                    if !request.description.isEmpty {
                        Text(request.description)
                            .font(.system(size: 13))
                            .foregroundColor(theme.textSecondary)
                            .lineLimit(2)
                            .lineSpacing(2)
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
                            .stroke(request.isApproved ? theme.border : theme.warning, lineWidth: 1)
                    )
            )
            .overlay(alignment: .topTrailing) {
                // Comment bubble
                ZStack {
                    Image(systemName: "bubble.right")
                        .font(.system(size: 30))
                        .foregroundColor(theme.accent)
                    Text("\(request.commentCount)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(theme.accent)
                        .offset(y: -3)
                }
                .offset(x: -8, y: 8)
            }
        }
        .buttonStyle(.plain)
        .opacity(request.isApproved ? 1 : 0.85)
    }
}
