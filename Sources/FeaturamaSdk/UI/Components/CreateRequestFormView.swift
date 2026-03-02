import SwiftUI

struct CreateRequestFormView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    let emailCollection: ProjectConfig.EmailCollection
    let onSubmit: (String, String, String?) async -> Void
    let onCancel: () -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var email = ""
    @State private var isSubmitting = false

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespaces)
    }

    private var isValid: Bool {
        if trimmedTitle.isEmpty { return false }
        if emailCollection == .required && email.trimmingCharacters(in: .whitespaces).isEmpty { return false }
        return true
    }

    var body: some View {
        VStack(spacing: 12) {
            TextField(strings.titlePlaceholder, text: $title)
                .textFieldStyle(.plain)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 8).fill(theme.secondary))
                .foregroundColor(theme.text)

            TextField(strings.descriptionPlaceholder, text: $description, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(3...6)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 8).fill(theme.secondary))
                .foregroundColor(theme.text)

            if emailCollection != .none {
                VStack(alignment: .leading, spacing: 4) {
                    TextField(strings.emailPlaceholder, text: $email)
                        .textFieldStyle(.plain)
                        #if canImport(UIKit)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 8).fill(theme.secondary))
                        .foregroundColor(theme.text)

                    Text(emailCollection == .required ? strings.emailRequired : strings.emailEncouragement)
                        .font(.system(size: 12))
                        .foregroundColor(theme.textSecondary)
                        .padding(.horizontal, 4)
                }
            }

            HStack(spacing: 12) {
                Button {
                    onCancel()
                } label: {
                    Text(strings.cancel)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 8).fill(theme.secondary))
                }
                .buttonStyle(.plain)

                Button {
                    guard isValid, !isSubmitting else { return }
                    isSubmitting = true
                    Task {
                        let emailValue = email.trimmingCharacters(in: .whitespaces)
                        await onSubmit(
                            trimmedTitle,
                            description.trimmingCharacters(in: .whitespaces),
                            emailValue.isEmpty ? nil : emailValue
                        )
                        title = ""
                        description = ""
                        email = ""
                        isSubmitting = false
                    }
                } label: {
                    HStack(spacing: 6) {
                        SendIconShape()
                            .stroke(theme.accentForeground, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                            .frame(width: 16, height: 16)
                        Text(strings.submit)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.accentForeground)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 8).fill(theme.accent))
                    .opacity(!isValid || isSubmitting ? 0.5 : 1)
                }
                .buttonStyle(.plain)
                .disabled(!isValid || isSubmitting)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(theme.borderAccent, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}
