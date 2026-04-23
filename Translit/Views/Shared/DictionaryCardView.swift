import SwiftUI

struct DictionaryCardView: View {
    let entry: DictionaryEntry
    let onTap: () -> Void
    let onCopy: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                Text(entry.meaning)
                    .font(AppTypography.heading(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(entry.outputText)
                    .font(AppTypography.ui(size: 13.5))
                    .foregroundStyle(.primary)
                    .lineLimit(4)

                HStack {
                    Text(DateFormatting.relativeDateString(timestamp: entry.updatedAt))
                        .font(AppTypography.ui(size: 10))
                        .foregroundStyle(.tertiary)

                    Spacer()

                    Button(action: onCopy) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                                .font(AppTypography.ui(size: 10, weight: .medium))
                            Text("Copy")
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
            .padding(16)
            .appGlassSurface(radius: AppTheme.Radius.card)
        }
        .buttonStyle(.plain)
    }
}
