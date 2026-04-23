import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    let onCopy: (String) -> Void

    var body: some View {
        HStack {
            if message.role == .assistant {
                bubble
                Spacer(minLength: 16)
            } else {
                Spacer(minLength: 16)
                bubble
            }
        }
    }

    private var bubble: some View {
        Text(message.content)
            .font(AppTypography.heading(size: 17, weight: .regular))
            .lineSpacing(4)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(backgroundShape)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.bubble, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .contextMenu {
                Button {
                    onCopy(message.content)
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
    }

    @ViewBuilder
    private var backgroundShape: some View {
        switch message.role {
        case .assistant:
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.bubble, style: .continuous)
                    .fill(AppTheme.surfaceMaterial)

                RoundedRectangle(cornerRadius: AppTheme.Radius.bubble, style: .continuous)
                    .fill(AppColors.surfaceOverlay)
            }
        case .user:
            RoundedRectangle(cornerRadius: AppTheme.Radius.bubble, style: .continuous)
                .fill(AppColors.userBubbleFill)
        }
    }

    private var borderColor: Color {
        switch message.role {
        case .assistant:
            return AppColors.glassStroke
        case .user:
            return AppColors.userBubbleStroke
        }
    }

    private var foregroundColor: Color {
        switch message.role {
        case .assistant:
            return .primary
        case .user:
            return .primary
        }
    }
}
