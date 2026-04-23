import SwiftUI

struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 52, weight: .thin))
                .foregroundStyle(.secondary)

            Text(title)
                .font(AppTypography.heading(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(AppTypography.ui(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
    }
}
