import SwiftUI

/// A pre-built SwiftUI view for displaying and managing feature requests.
///
/// Uses the `FeaturamaSdk.shared` singleton internally. Make sure to call
/// `FeaturamaSdk.configure(apiKey:)` before using this view.
///
/// Example:
/// ```swift
/// FeaturamaView(
///     accentColor: .indigo,
///     onClose: { dismiss() }
/// )
/// ```
public struct FeaturamaView: View {
    private let accentColor: Color
    private let preferredColorScheme: ColorScheme?
    private let themeOverrides: FeaturamaThemeOverrides?
    private let onClose: (() -> Void)?
    private let strings: FeaturamaStrings

    public init(
        accentColor: Color = .blue,
        colorScheme: ColorScheme? = nil,
        theme: FeaturamaThemeOverrides? = nil,
        onClose: (() -> Void)? = nil,
        strings: FeaturamaStrings = FeaturamaStrings()
    ) {
        self.accentColor = accentColor
        self.preferredColorScheme = colorScheme
        self.themeOverrides = theme
        self.onClose = onClose
        self.strings = strings
    }

    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var activeFilter = "new"
    @State private var isAdding = false
    @State private var items: [FeatureRequest]? = nil
    @State private var isLoading = false
    @State private var error: String? = nil
    @State private var votingIds: Set<String> = []

    // Config
    @State private var config: ProjectConfig? = nil

    // Detail view state
    @State private var selectedRequest: FeatureRequest? = nil
    @State private var comments: [Comment] = []
    @State private var isLoadingComments = false
    @State private var isSubmittingComment = false
    @State private var commentVotingIds: Set<String> = []

    private var effectiveColorScheme: ColorScheme {
        preferredColorScheme ?? systemColorScheme
    }

    private var theme: FeaturamaTheme {
        ThemeFactory.create(accentColor: accentColor, colorScheme: effectiveColorScheme)
            .applying(themeOverrides)
    }

    private var voterId: String {
        VoterIdProvider.getOrCreate()
    }

    private var showBranding: Bool {
        config?.branding.showBranding ?? true
    }

    private var emailCollection: ProjectConfig.EmailCollection {
        config?.emailCollection ?? .none
    }

    public var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            if let selected = selectedRequest {
                // Detail view
                RequestDetailView(
                    theme: theme,
                    strings: strings,
                    request: selected,
                    comments: comments,
                    isLoadingComments: isLoadingComments,
                    isSubmittingComment: isSubmittingComment,
                    isVotingRequest: votingIds.contains(selected.id),
                    commentVotingIds: commentVotingIds,
                    onBack: handleBack,
                    onToggleRequestVote: { handleToggleVoteInDetail() },
                    onToggleCommentVote: handleToggleCommentVote,
                    onAddComment: handleAddComment
                )
            } else {
                // List view
                VStack(spacing: 0) {
                    HeaderView(
                        theme: theme,
                        strings: strings,
                        onClose: onClose ?? { dismiss() },
                        onAdd: { isAdding = true }
                    )

                    FilterTabsView(
                        theme: theme,
                        strings: strings,
                        activeFilter: $activeFilter
                    )

                    Spacer().frame(height: 12)

                    if isAdding {
                        CreateRequestFormView(
                            theme: theme,
                            strings: strings,
                            emailCollection: emailCollection,
                            onSubmit: { title, desc, email in
                                let req = CreateFeatureRequest(
                                    title: title,
                                    description: desc,
                                    submitterIdentifier: voterId,
                                    email: email
                                )
                                _ = try? await FeaturamaSdk.createRequest(req)
                                isAdding = false
                                await loadData()
                            },
                            onCancel: { isAdding = false }
                        )
                    }

                    FeaturamaRequestListView(
                        theme: theme,
                        strings: strings,
                        items: items,
                        isLoading: isLoading,
                        error: error,
                        votingIds: votingIds,
                        onToggleVote: { requestId in
                            guard !votingIds.contains(requestId) else { return }
                            votingIds.insert(requestId)
                            Task {
                                defer { votingIds.remove(requestId) }
                                _ = try? await FeaturamaSdk.toggleVote(requestId: requestId, voterIdentifier: voterId)
                                await loadData()
                            }
                        },
                        onRequestPress: { request in
                            handleRequestPress(request)
                        },
                        onRefresh: { await loadData() }
                    )

                    if showBranding {
                        BrandingView(theme: theme)
                            .padding(.bottom, 16)
                    }
                }
            }
        }
        .task {
            config = try? await FeaturamaSdk.getConfig()
        }
        .task(id: activeFilter) {
            if selectedRequest == nil {
                await loadData()
            }
        }
    }

    // MARK: - Data Loading

    private func loadData() async {
        isLoading = true
        error = nil
        do {
            let response = try await FeaturamaSdk.getRequests(pageSize: 50, filter: activeFilter, submitterIdentifier: voterId)
            items = response.items
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Detail View Handlers

    private func handleRequestPress(_ request: FeatureRequest) {
        selectedRequest = request
        comments = []
        isLoadingComments = true
        Task {
            do {
                comments = try await FeaturamaSdk.getComments(requestId: request.id)
            } catch {
                // Silently fail, show empty comments
            }
            isLoadingComments = false
        }
    }

    private func handleBack() {
        selectedRequest = nil
        comments = []
        Task { await loadData() }
    }

    private func handleToggleVoteInDetail() {
        guard let request = selectedRequest else { return }
        guard !votingIds.contains(request.id) else { return }
        votingIds.insert(request.id)
        Task {
            defer { votingIds.remove(request.id) }
            if let updated = try? await FeaturamaSdk.toggleVote(requestId: request.id, voterIdentifier: voterId) {
                selectedRequest = updated
            }
        }
    }

    private func handleToggleCommentVote(_ commentId: String) {
        guard let request = selectedRequest else { return }
        guard !commentVotingIds.contains(commentId) else { return }
        commentVotingIds.insert(commentId)
        Task {
            defer { commentVotingIds.remove(commentId) }
            if let updated = try? await FeaturamaSdk.toggleCommentVote(
                requestId: request.id,
                commentId: commentId,
                voterIdentifier: voterId
            ) {
                if let index = comments.firstIndex(where: { $0.id == commentId }) {
                    comments[index] = updated
                }
            }
        }
    }

    private func handleAddComment(_ content: String) {
        guard let request = selectedRequest else { return }
        isSubmittingComment = true
        Task {
            let input = CreateCommentRequest(
                content: content,
                authorIdentifier: voterId
            )
            if let comment = try? await FeaturamaSdk.addComment(requestId: request.id, input: input) {
                comments.append(comment)
            }
            isSubmittingComment = false
        }
    }
}
