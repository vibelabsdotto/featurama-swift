import SwiftUI

struct AddCommentFormView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    let isSubmitting: Bool
    let onSubmit: (String) async throws -> Void

    @State private var submissionError: String?

    @State private var content = ""

    private var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField(strings.commentPlaceholder, text: $content, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.background)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(theme.border, lineWidth: 1))
                )
                .foregroundColor(theme.text)
                .disabled(isSubmitting)

            Button(action: {
                guard !trimmedContent.isEmpty, !isSubmitting else { return }
                Task {
                    do {
                        try await onSubmit(trimmedContent)
                        content = ""
                    } catch {
                        submissionError = error.localizedDescription
                    }
                }
            }) {
                if isSubmitting {
                    ProgressView()
                        .tint(theme.accentForeground)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 15))
                        .foregroundColor(trimmedContent.isEmpty ? theme.textSecondary : theme.accentForeground)
                }
            }
            .frame(width: 36, height: 36)
            .background(
                Circle().fill(trimmedContent.isEmpty ? theme.accentLight : theme.accent)
            )
            .buttonStyle(.plain)
            .disabled(trimmedContent.isEmpty || isSubmitting)
            .accessibilityLabel(strings.postComment)
        }
        .alert(strings.error, isPresented: Binding(
            get: { submissionError != nil },
            set: { if !$0 { submissionError = nil } }
        )) {
            Button(strings.cancel, role: .cancel) { submissionError = nil }
        } message: {
            Text(submissionError ?? "")
        }
        .padding(12)
        .background(theme.card)
        .overlay(alignment: .top) {
            Rectangle().fill(theme.border).frame(height: 1)
        }
    }
}
