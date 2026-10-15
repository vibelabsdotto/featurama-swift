import SwiftUI

struct ShippedReviewCardView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    let shipped: ShippedReview.Shipped
    let storeURL: URL
    let onPress: () -> Void
    let onDismiss: () -> Void

    @Environment(\.openURL) private var openURL
    @State private var openFailed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                Button(action: onPress) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(shipped.isOwn ? strings.shippedTitleOwn : strings.shippedTitleVoted)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(theme.text)
                        Text(strings.shippedBody.replacingOccurrences(of: "{title}", with: shipped.request.title))
                            .font(.system(size: 13))
                            .foregroundColor(theme.textSecondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(theme.textSecondary)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(strings.dismiss)
            }

            Button {
                openFailed = false
                openURL(storeURL) { accepted in openFailed = !accepted }
            } label: {
                Text(strings.rateApp)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.accent)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.plain)

            if openFailed {
                Text(strings.rateOpenError)
                    .font(.system(size: 13))
                    .foregroundColor(theme.text)
                    .padding(.bottom, 8)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 4)
        .background(RoundedRectangle(cornerRadius: 12).fill(theme.accentLight))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(theme.borderAccent, lineWidth: 1))
    }
}
