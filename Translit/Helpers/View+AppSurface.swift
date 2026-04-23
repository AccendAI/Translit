import SwiftUI

extension View {
    func appGlassSurface(
        radius: CGFloat = AppTheme.Radius.card,
        stroke: Color = AppColors.glassStroke
    ) -> some View {
        background {
            ZStack {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(AppTheme.surfaceMaterial)

                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(AppColors.surfaceOverlay)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(stroke, lineWidth: 1)
        }
    }
}
