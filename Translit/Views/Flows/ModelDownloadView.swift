import SwiftUI

struct ModelDownloadView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Download the On-Device Model")
                        .font(AppTypography.heading(size: 28, weight: .semibold))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Translit runs locally after you download the model. This is a one time setup.")
                        .font(AppTypography.ui(size: 13.5))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(AppColors.tint)
                            .frame(width: 44, height: 44)
                            .background(AppColors.badgeBackground, in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(store.localModelStatusText)
                                .font(AppTypography.ui(size: 16, weight: .semibold))
                                .foregroundStyle(.primary)

                            Text("The first download can take a few minutes depending on your connection. After it finishes, translations run on-device.")
                                .font(AppTypography.ui(size: 13))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    if store.isPreparingLocalModel {
                        VStack(alignment: .leading, spacing: 8) {
                            ProgressView(value: store.modelDownloadProgress)
                                .progressViewStyle(.linear)

                            HStack {
                                Text("Downloading model…")
                                    .font(AppTypography.ui(size: 12.5, weight: .medium))
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Text("\(Int(store.modelDownloadProgress * 100))%")
                                    .font(AppTypography.ui(size: 12.5, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                        }
                    }

                    if let errorMessage = store.modelPreparationErrorMessage {
                        Text(errorMessage)
                            .font(AppTypography.ui(size: 12.5, weight: .medium))
                            .foregroundStyle(AppColors.destructive)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button {
                        Task {
                            await store.prepareLocalModel()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if store.isPreparingLocalModel {
                                ProgressView()
                                    .controlSize(.small)
                                    .tint(.white)
                            }

                            Text(store.isPreparingLocalModel ? "Downloading…" : "Download Model")
                                .font(AppTypography.ui(size: 14, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(.white)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                                .fill(AppColors.tint)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(store.isPreparingLocalModel)
                    .opacity(store.isPreparingLocalModel ? 0.75 : 1)
                }
                .padding(20)
                .appGlassSurface(radius: AppTheme.Radius.card)
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appSystemBackground.ignoresSafeArea())
    }
}

#Preview {
    ModelDownloadView()
        .environment(AppStore())
}
