import SwiftUI

struct ToastOverlayView: View {
    let toast: ToastMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(AppTypography.ui(size: 13, weight: .semibold))
                .foregroundStyle(Color.white)

            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .font(AppTypography.ui(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white)

                if let subtitle = toast.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(AppTypography.ui(size: 11))
                        .foregroundStyle(Color.white.opacity(0.88))
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.bubble, style: .continuous))
        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
    }

    private var iconName: String {
        switch toast.style {
        case .success:
            return "checkmark.circle.fill"
        case .info:
            return "info.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }

    private var backgroundColor: Color {
        switch toast.style {
        case .success:
            return Color.green.opacity(0.85)
        case .info:
            return Color.blue.opacity(0.85)
        case .error:
            return Color.red.opacity(0.88)
        }
    }
}
