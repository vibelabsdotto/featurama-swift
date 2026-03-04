import SwiftUI

struct FabView: View {
    let theme: FeaturamaTheme
    let onPress: () -> Void

    var body: some View {
        Button(action: onPress) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(theme.accentForeground)
        }
        .frame(width: 56, height: 56)
        .background(Circle().fill(theme.accent))
        .shadow(color: .black.opacity(0.3), radius: 4, y: 4)
        .buttonStyle(.plain)
    }
}
