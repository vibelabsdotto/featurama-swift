import SwiftUI

struct HeaderView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    let onClose: (() -> Void)?

    var body: some View {
        HStack {
            Button(action: { onClose?() }) {
                if onClose != nil {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.text)
                } else {
                    Color.clear.frame(width: 22, height: 22)
                }
            }
            .frame(width: 44, height: 44)
            .disabled(onClose == nil)

            Spacer()

            Text(strings.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(theme.text)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .padding(.top, 8)
        .overlay(alignment: .bottom) {
            Rectangle().fill(theme.border).frame(height: 0.5)
        }
    }
}
