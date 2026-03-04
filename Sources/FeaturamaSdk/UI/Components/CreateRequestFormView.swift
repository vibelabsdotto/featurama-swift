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
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.text)
                }
                .frame(width: 44, height: 44)
                .buttonStyle(.plain)

                Text(strings.newRequest)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.text)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)

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
                    if isSubmitting {
                        ProgressView()
                            .tint(theme.accentForeground)
                    } else {
                        Text(strings.submit)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isValid ? theme.accentForeground : theme.textSecondary)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 8).fill(isValid ? theme.accent : theme.accentLight))
                .buttonStyle(.plain)
                .disabled(!isValid || isSubmitting)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .padding(.top, 8)
            .overlay(alignment: .bottom) {
                Rectangle().fill(theme.border).frame(height: 0.5)
            }

            // Form body
            ScrollView {
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
                }
                .padding(16)
            }
        }
    }
}
