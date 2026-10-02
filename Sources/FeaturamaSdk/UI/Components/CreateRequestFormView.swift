import SwiftUI

struct CreateRequestFormView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    let emailCollection: ProjectConfig.EmailCollection
    let onSubmit: (String, String, String?) async throws -> Void
    var request: FeatureRequest? = nil
    let onCancel: () -> Void

    @State private var submissionError: String?
    @State private var title = ""
    @State private var description = ""
    @State private var email = ""
    @State private var isSubmitting = false
    @State private var emailTouched = false
    @State private var showEmailSkipAlert = false

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespaces)
    }

    private static let emailRegex: NSPredicate = {
        let pattern = "[^\\s@]+@[^\\s@]+\\.[^\\s@]+"
        return NSPredicate(format: "SELF MATCHES %@", pattern)
    }()

    private var emailError: String? {
        guard emailCollection != .none else { return nil }
        guard !trimmedEmail.isEmpty else { return nil }
        guard Self.emailRegex.evaluate(with: trimmedEmail) else {
            return strings.emailInvalid
        }
        return nil
    }

    private var isValid: Bool {
        if trimmedTitle.isEmpty || description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        if emailError != nil { return false }
        if emailCollection == .required && trimmedEmail.isEmpty { return false }
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
                .disabled(isSubmitting)
                .accessibilityLabel(strings.cancel)

                Text(request == nil ? strings.newRequest : strings.editRequest)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(theme.text)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)

                Button {
                    guard isValid, !isSubmitting else { return }
                    if emailCollection == .optional && trimmedEmail.isEmpty {
                        showEmailSkipAlert = true
                        return
                    }
                    performSubmit()
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
                    if let submissionError {
                        Text(submissionError).foregroundColor(.red)
                    }
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
                                .onChange(of: email) { _ in
                                    if !emailTouched { emailTouched = true }
                                }

                            if let error = emailError, emailTouched {
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 4)
                            } else {
                                Text(emailCollection == .required ? strings.emailRequired : strings.emailEncouragement)
                                    .font(.system(size: 12))
                                    .foregroundColor(theme.textSecondary)
                                    .padding(.horizontal, 4)
                            }
                        }
                    }
                }
                .padding(16)
            }
        }
        .onAppear {
            if let request {
                title = request.title
                description = request.description
            }
        }
        .alert(strings.emailSkipTitle, isPresented: $showEmailSkipAlert) {
            Button(strings.cancel, role: .cancel) { }
            Button(strings.emailSkipConfirm) {
                performSubmit()
            }
        } message: {
            Text(strings.emailSkipMessage)
        }
    }

    private func performSubmit() {
        isSubmitting = true
        Task {
            defer { isSubmitting = false }
            submissionError = nil
            do {
                try await onSubmit(
                    trimmedTitle,
                    description.trimmingCharacters(in: .whitespacesAndNewlines),
                    trimmedEmail.isEmpty ? nil : trimmedEmail
                )
            } catch {
                submissionError = error.localizedDescription
            }
        }
    }
}
