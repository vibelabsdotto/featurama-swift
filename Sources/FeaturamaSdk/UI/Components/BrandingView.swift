import SwiftUI

struct BrandingView: View {
    let theme: FeaturamaTheme

    var body: some View {
        Link(destination: URL(string: "https://featurama.app")!) {
            HStack(spacing: 6) {
                FeaturamaLogoIcon(
                    size: 16,
                    color: theme.accent,
                    checkmarkColor: theme.gray100
                )

                Text("Powered by Featurama")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(theme.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(theme.gray100)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
        }
    }
}
