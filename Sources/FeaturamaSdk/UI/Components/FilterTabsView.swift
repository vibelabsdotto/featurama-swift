import SwiftUI

struct FilterTabsView: View {
    let theme: FeaturamaTheme
    let strings: FeaturamaStrings
    @Binding var activeFilter: String

    private var filters: [(key: String, label: String)] {
        [
            ("new", strings.filterNew),
            ("planned", strings.filterPlanned),
            ("in_progress", strings.filterInProgress),
            ("done", strings.filterDone),
        ]
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(filters, id: \.key) { filter in
                let isActive = filter.key == activeFilter
                Button {
                    activeFilter = filter.key
                } label: {
                    Text(filter.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isActive ? theme.text : theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if isActive {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(theme.card)
                                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.gray100)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}
