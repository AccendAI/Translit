import SwiftUI

struct HistoryCardView: View {
    let entry: HistoryEntry
    let onCopy: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let meaning = entry.meaning, !meaning.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    sectionTitle("Meaning")
                    Text(meaning)
                        .font(AppTypography.ui(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                sectionTitle("Output")
                Text(entry.outputText)
                    .font(AppTypography.ui(size: 13.5))
                    .foregroundStyle(.primary)
                    .lineLimit(4)
            }

            HStack {
                Text(DateFormatting.relativeDateString(timestamp: entry.timestamp))
                    .font(AppTypography.ui(size: 10))
                    .foregroundStyle(.tertiary)

                Spacer()

                HStack(spacing: 8) {
                    actionButton(title: "Copy", icon: "doc.on.doc", action: onCopy)
                    actionButton(title: "Save", icon: "bookmark", action: onSave)
                }
            }
            .padding(.top, 2)
        }
        .padding(16)
        .appGlassSurface(radius: AppTheme.Radius.card)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(AppTypography.ui(size: 11, weight: .semibold))
            .foregroundStyle(.tertiary)
    }

    private func actionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(AppTypography.ui(size: 10, weight: .medium))
                Text(title)
                    .font(AppTypography.ui(size: 11, weight: .medium))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColors.badgeBackground)
            .foregroundStyle(AppColors.badgeForeground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
