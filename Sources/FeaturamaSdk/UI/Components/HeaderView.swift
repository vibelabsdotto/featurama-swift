import SwiftUI

struct HeaderView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    let onClose: (() -> Void)?
    let onAdd: () -> Void

    var body: some View {
        HStack {
            Button(action: { onClose?() }) {
                if onClose != nil {
                    CloseIconShape()
                        .stroke(theme.text, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .frame(width: 24, height: 24)
                } else {
                    Color.clear.frame(width: 24, height: 24)
                }
            }
            .frame(width: 40, height: 40)
            .disabled(onClose == nil)

            Spacer()

            Text(strings.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.text)

            Spacer()

            Button(action: onAdd) {
                PlusIconShape()
                    .stroke(theme.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: 24, height: 24)
            }
            .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 16)
        .padding(.top, 8)
    }
}
