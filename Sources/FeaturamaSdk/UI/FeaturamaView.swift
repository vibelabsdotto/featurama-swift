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
@MainActor
public struct FeaturamaView: View {
    private let accentColor: Color
    private let preferredColorScheme: ColorScheme?
    private let themeOverrides: FeaturamaThemeOverrides?
    private let onClose: (() -> Void)?
    private let strings: FeaturamaStrings
    private let submitterIdentifier: String?

    public init(
        accentColor: Color = .blue,
        colorScheme: ColorScheme? = nil,
        theme: FeaturamaThemeOverrides? = nil,
        onClose: (() -> Void)? = nil,
        strings: FeaturamaStrings = FeaturamaStrings(),
        submitterIdentifier: String? = nil
    ) {
        self.accentColor = accentColor
        self.preferredColorScheme = colorScheme
        self.themeOverrides = theme
        self.onClose = onClose
        self.strings = strings
        self.submitterIdentifier = submitterIdentifier
    }

    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var activeFilter = "new"
    @State private var isAdding = false
    @State private var editingRequest: FeatureRequest?
    @State private var actionError: String?
    @State private var commentsError: String?
    @State private var page = 0
    @State private var hasNextPage = false
    @State private var loadGeneration = UUID()
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
        if let submitterIdentifier, !submitterIdentifier.isEmpty { return submitterIdentifier }
        return VoterIdProvider.getOrCreate()
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

            if let editing = editingRequest {
                CreateRequestFormView(
                    theme: theme, strings: strings, emailCollection: .none,
                    onSubmit: { title, description, _ in
                        let updated = try await FeaturamaSdk.updateRequest(
                            id: editing.id,
                            updateRequest: UpdateFeatureRequest(title: title, description: description, submitterIdentifier: voterId)
                        )
                        selectedRequest = updated.withVotingState(editing.hasVoted)
                        editingRequest = nil
                        await loadData()
                    },
                    request: editing,
                    onCancel: { editingRequest = nil }
                )
            } else if let selected = selectedRequest {
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
                    onAddComment: handleAddComment,
                    isOwner: selected.submitterIdentifier == voterId,
                    commentsError: commentsError,
                    onRetryComments: { Task { await loadComments(selected.id) } },
                    onEdit: { editingRequest = selected }
                )
            } else if isAdding {
                // Create request form (full screen)
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
                        _ = try await FeaturamaSdk.createRequest(req)
                        isAdding = false
                        activeFilter = "new"
                        await loadData()
                    },
                    onCancel: { isAdding = false }
                )
            } else {
                // List view
                VStack(spacing: 0) {
                    HeaderView(
                        theme: theme,
                        strings: strings,
                        onClose: onClose ?? { dismiss() }
                    )

                    FilterTabsView(
                        theme: theme,
                        strings: strings,
                        activeFilter: $activeFilter
                    )

                    Spacer().frame(height: 12)

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
                                do {
                                    _ = try await FeaturamaSdk.toggleVote(requestId: requestId, voterIdentifier: voterId)
                                    await loadData()
                                } catch { actionError = error.localizedDescription }
                            }
                        },
                        onRequestPress: { request in
                            handleRequestPress(request)
                        },
                        onRefresh: { await loadData() },
                        hasNextPage: hasNextPage,
                        onLoadMore: { await loadData(append: true) }
                    )
                }
                .overlay(alignment: .bottom) {
                    ZStack(alignment: .bottom) {
                        if showBranding {
                            BrandingView(theme: theme)
                        }

                        HStack {
                            Spacer()
                            FabView(theme: theme, onPress: {
                                Task {
                                    do {
                                        config = try await FeaturamaSdk.getConfig()
                                        isAdding = true
                                    } catch { actionError = error.localizedDescription }
                                }
                            })
                                .accessibilityLabel(strings.newRequest)
                                .padding(.trailing, 16)
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
        .task {
            do { config = try await FeaturamaSdk.getConfig() }
            catch { actionError = error.localizedDescription }
        }
        .task(id: activeFilter) {
            if selectedRequest == nil {
                items = nil
                await loadData()
            }
        }
        .alert(strings.error, isPresented: Binding(
            get: { actionError != nil },
            set: { if !$0 { actionError = nil } }
        )) {
            Button(strings.cancel, role: .cancel) { actionError = nil }
        } message: { Text(actionError ?? "") }
    }

    // MARK: - Data Loading

    private func loadData(append: Bool = false) async {
        if append && (isLoading || !hasNextPage) { return }
        let generation = UUID()
        loadGeneration = generation
        let filter = activeFilter
        let nextPage = append ? page + 1 : 1
        isLoading = true
        error = nil
        defer { if loadGeneration == generation { isLoading = false } }
        do {
            let response = try await FeaturamaSdk.getRequests(page: nextPage, pageSize: 50, filter: filter, submitterIdentifier: voterId)
            guard !Task.isCancelled, loadGeneration == generation, activeFilter == filter else { return }
            if append {
                let existingIds = Set((items ?? []).map(\.id))
                items = (items ?? []) + response.items.filter { !existingIds.contains($0.id) }
            } else { items = response.items }
            page = response.page
            hasNextPage = response.hasNextPage
        } catch {
            guard !Task.isCancelled, loadGeneration == generation else { return }
            self.error = error.localizedDescription
        }
    }

    // MARK: - Detail View Handlers

    private func handleRequestPress(_ request: FeatureRequest) {
        selectedRequest = request
        comments = []
        commentsError = nil
        Task { await loadComments(request.id) }
    }

    private func loadComments(_ requestId: String) async {
        guard selectedRequest?.id == requestId else { return }
        isLoadingComments = true
        commentsError = nil
        defer { if selectedRequest?.id == requestId { isLoadingComments = false } }
        do {
            let loaded = try await FeaturamaSdk.getComments(requestId: requestId)
            guard selectedRequest?.id == requestId else { return }
            comments = loaded
        } catch {
            guard selectedRequest?.id == requestId else { return }
            commentsError = error.localizedDescription
        }
    }

    private func handleBack() {
        selectedRequest = nil
        comments = []
        Task { await loadData() }
    }

    private func handleToggleVoteInDetail() {
        guard let request = selectedRequest, request.isApproved, !votingIds.contains(request.id) else { return }
        votingIds.insert(request.id)
        Task {
            defer { votingIds.remove(request.id) }
            do {
                let updated = try await FeaturamaSdk.toggleVote(requestId: request.id, voterIdentifier: voterId)
                guard selectedRequest?.id == request.id else { return }
                selectedRequest = updated.withVotingState(updated.hasVoted, submitterIdentifier: request.submitterIdentifier)
            } catch { actionError = error.localizedDescription }
        }
    }

    private func handleToggleCommentVote(_ commentId: String) {
        guard let request = selectedRequest else { return }
        guard !commentVotingIds.contains(commentId) else { return }
        commentVotingIds.insert(commentId)
        Task {
            defer { commentVotingIds.remove(commentId) }
            do {
                let updated = try await FeaturamaSdk.toggleCommentVote(
                requestId: request.id,
                commentId: commentId,
                voterIdentifier: voterId
                )
                guard selectedRequest?.id == request.id else { return }
                if let index = comments.firstIndex(where: { $0.id == commentId }) {
                    comments[index] = updated
                }
            } catch { actionError = error.localizedDescription }
        }
    }

    private func handleAddComment(_ content: String) async throws {
        guard let request = selectedRequest, !isSubmittingComment else { return }
        isSubmittingComment = true
        defer { isSubmittingComment = false }
        let input = CreateCommentRequest(content: content, authorIdentifier: voterId)
        let comment = try await FeaturamaSdk.addComment(requestId: request.id, input: input)
        guard selectedRequest?.id == request.id else { return }
        comments.append(comment)
    }
}
