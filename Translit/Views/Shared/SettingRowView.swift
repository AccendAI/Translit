import SwiftUI

struct SettingRowView: View {
    let systemImage: String
    let label: String
    let value: String?
    let isExternal: Bool
    let action: () -> Void

    init(systemImage: String, label: String, value: String? = nil, isExternal: Bool = false, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.label = label
        self.value = value
        self.isExternal = isExternal
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                        .fill(AppColors.badgeBackground)
                    Image(systemName: systemImage)
                        .font(AppTypography.ui(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.tint)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(AppTypography.ui(size: 13.5, weight: .medium))
                        .foregroundStyle(.primary)

                    if let value {
                        Text(value)
                            .font(AppTypography.ui(size: 12))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: isExternal ? "arrow.up.right" : "chevron.right")
                    .font(AppTypography.ui(size: 10, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .appGlassSurface(radius: AppTheme.Radius.card)
        }
        .buttonStyle(.plain)
    }
}
