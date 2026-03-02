import SwiftUI

struct RequestDetailView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    let request: FeatureRequest
    let comments: [Comment]
    let isLoadingComments: Bool
    let isSubmittingComment: Bool
    let isVotingRequest: Bool
    let commentVotingIds: Set<String>
    let onBack: () -> Void
    let onToggleRequestVote: () -> Void
    let onToggleCommentVote: (String) -> Void
    let onAddComment: (String) -> Void

    private var statusLabel: String {
        switch request.status {
        case .requested: return strings.filterNew
        case .roadmap: return strings.badgePlanned
        case .inProgress: return strings.filterInProgress
        case .done: return strings.filterDone
        case .declined: return "Declined"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Button(action: onBack) {
                    ChevronLeftIconShape()
                        .stroke(theme.text, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .frame(width: 20, height: 20)
                }
                .frame(width: 28, height: 28)
                .buttonStyle(.plain)

                Text(request.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.text)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)

                Color.clear.frame(width: 28, height: 28)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .padding(.top, 8)
            .overlay(alignment: .bottom) {
                Rectangle().fill(theme.border).frame(height: 1)
            }

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    Text(request.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.text)
                        .padding(.bottom, 8)

                    // Badge row
                    HStack(spacing: 8) {
                        Text(statusLabel)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(theme.accent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(RoundedRectangle(cornerRadius: 6).fill(theme.accentLight))

                        if !request.isApproved {
                            Text(strings.pendingReview)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(theme.warningText)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                                .background(RoundedRectangle(cornerRadius: 6).fill(theme.warningLight))
                        }
                    }
                    .padding(.bottom, 12)

                    // Description
                    if !request.description.isEmpty {
                        Text(request.description)
                            .font(.system(size: 15))
                            .foregroundColor(theme.textSecondary)
                            .lineSpacing(4)
                            .padding(.bottom, 16)
                    }

                    // Vote button
                    Button(action: onToggleRequestVote) {
                        HStack(spacing: 6) {
                            if isVotingRequest {
                                ProgressView()
                                    .tint(theme.accent)
                            } else {
                                ChevronUpIconShape()
                                    .stroke(theme.accent, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                    .frame(width: 18, height: 18)
                                Text("\(request.voteCount)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(theme.accent)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(RoundedRectangle(cornerRadius: 8).fill(theme.accentLight))
                    }
                    .buttonStyle(.plain)
                    .disabled(isVotingRequest || !request.isApproved)

                    // Divider
                    Rectangle()
                        .fill(theme.border)
                        .frame(height: 1)
                        .padding(.vertical, 20)

                    // Comments section
                    Text("\(strings.comments) (\(comments.count))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.text)
                        .padding(.bottom, 12)

                    if isLoadingComments {
                        HStack {
                            Spacer()
                            ProgressView().tint(theme.accent)
                            Spacer()
                        }
                        .padding(.top, 16)
                    } else if comments.isEmpty {
                        VStack(spacing: 4) {
                            Text(strings.noComments)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(theme.textSecondary)
                            Text(strings.noCommentsHint)
                                .font(.system(size: 13))
                                .foregroundColor(theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        ForEach(comments) { comment in
                            CommentItemView(
                                theme: theme,
                                strings: strings,
                                comment: comment,
                                isVoting: commentVotingIds.contains(comment.id),
                                onToggleVote: onToggleCommentVote
                            )
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }

            // Add comment form
            if request.isApproved {
                AddCommentFormView(
                    theme: theme,
                    strings: strings,
                    isSubmitting: isSubmittingComment,
                    onSubmit: onAddComment
                )
            }
        }
    }
}
