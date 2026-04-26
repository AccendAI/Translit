import SwiftUI

struct ModelDownloadView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var pendingDeleteModelID: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                if let errorMessage = store.modelPreparationErrorMessage {
                    Text(errorMessage)
                        .font(AppTypography.ui(size: 12.5, weight: .medium))
                        .foregroundStyle(AppColors.destructive)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .appGlassSurface(radius: AppTheme.Radius.medium, stroke: AppColors.destructive.opacity(0.22))
                }

                VStack(spacing: 14) {
                    ForEach(store.availableModels) { model in
                        modelCard(model)
                    }
                }

                if !store.hasAnyDownloadedModels {
                    Text("Download one model to start translating locally. You can remove it later and download it again at any time.")
                        .font(AppTypography.ui(size: 12.5))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: 640, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(Color.appSystemBackground.ignoresSafeArea())
        .navigationTitle("On-Device Models")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    store.dismissModelManagement()
                    dismiss()
                }
            }
        }
        .alert("Delete Model", isPresented: deleteAlertBinding) {
            Button("Cancel", role: .cancel) {
                pendingDeleteModelID = nil
            }
            Button("Delete", role: .destructive) {
                guard let modelID = pendingDeleteModelID else {
                    return
                }

                Task {
                    await store.deleteDownloadedModel(modelID)
                }
                pendingDeleteModelID = nil
            }
        } message: {
            Text(deleteAlertMessage)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(store.hasAnyDownloadedModels ? "Manage your on-device models" : "Download an on-device model")
                .font(AppTypography.heading(size: 24, weight: .semibold))
                .fixedSize(horizontal: false, vertical: true)

            Text("Models run on-device after download. Select one to use, or remove and redownload as needed.")
                .font(AppTypography.ui(size: 13.5))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func modelCard(_ model: OnDeviceModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "cpu")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.tint)
                    .frame(width: 42, height: 42)
                    .background(AppColors.badgeBackground, in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(model.displayName)
                            .font(AppTypography.ui(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)

                        if model.isRecommended {
                            statusChip("Recommended", foreground: AppColors.tint, background: AppColors.badgeBackground)
                        }

                        if store.selectedModelID == model.id, store.isModelDownloaded(model.id) {
                            statusChip("Selected", foreground: .green, background: Color.green.opacity(0.14))
                        } else if store.isModelDownloaded(model.id) {
                            statusChip("Downloaded", foreground: .green, background: Color.green.opacity(0.14))
                        }
                    }

                    Text(model.subtitle)
                        .font(AppTypography.ui(size: 13))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(model.storageDescription)
                        .font(AppTypography.ui(size: 12, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
            }

            if store.isPreparingModel(model.id) {
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

            HStack(spacing: 10) {
                primaryActionButton(for: model)

                if store.isModelDownloaded(model.id) {
                    Button(role: .destructive) {
                        pendingDeleteModelID = model.id
                    } label: {
                        if store.isDeletingModel(model.id) {
                            ProgressView()
                                .controlSize(.small)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                        } else {
                            Text("Delete")
                                .font(AppTypography.ui(size: 13.5, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(AppColors.destructive)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                            .fill(AppColors.destructive.opacity(0.12))
                    )
                    .disabled(store.isDeletingModel(model.id) || store.isPreparingLocalModel)
                }
            }
        }
        .padding(18)
        .appGlassSurface(radius: AppTheme.Radius.card)
    }

    private func primaryActionButton(for model: OnDeviceModel) -> some View {
        Button {
            Task {
                if store.isModelDownloaded(model.id) {
                    await store.selectModel(model.id)
                } else {
                    await store.prepareLocalModel(modelID: model.id)
                }
            }
        } label: {
            HStack(spacing: 10) {
                if store.isPreparingModel(model.id) {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                }

                Text(primaryActionTitle(for: model))
                    .font(AppTypography.ui(size: 13.5, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .foregroundStyle(primaryActionForegroundColor(for: model))
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                    .fill(primaryActionBackgroundColor(for: model))
            )
        }
        .buttonStyle(.plain)
        .disabled(primaryActionDisabled(for: model))
        .opacity(primaryActionDisabled(for: model) ? 0.75 : 1)
    }

    private func primaryActionTitle(for model: OnDeviceModel) -> String {
        if store.isPreparingModel(model.id) {
            return "Downloading…"
        }

        if store.isModelDownloaded(model.id) {
            return store.selectedModelID == model.id ? "Selected" : "Use Model"
        }

        return "Download Model"
    }

    private func primaryActionDisabled(for model: OnDeviceModel) -> Bool {
        if store.isPreparingLocalModel || store.isDeletingModel(model.id) {
            return true
        }

        return store.isModelDownloaded(model.id) && store.selectedModelID == model.id
    }

    private func primaryActionBackgroundColor(for model: OnDeviceModel) -> Color {
        if store.isModelDownloaded(model.id) && store.selectedModelID == model.id {
            return Color.primary.opacity(0.08)
        }

        return AppColors.tint
    }

    private func primaryActionForegroundColor(for model: OnDeviceModel) -> Color {
        if store.isModelDownloaded(model.id) && store.selectedModelID == model.id {
            return .primary
        }

        return .white
    }

    private func statusChip(_ title: String, foreground: Color, background: Color) -> some View {
        Text(title)
            .font(AppTypography.ui(size: 10.5, weight: .semibold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(background, in: Capsule())
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { pendingDeleteModelID != nil },
            set: { isPresented in
                if !isPresented {
                    pendingDeleteModelID = nil
                }
            }
        )
    }

    private var deleteAlertMessage: String {
        guard let pendingDeleteModelID else {
            return ""
        }

        return "Remove \(OnDeviceModel.details(for: pendingDeleteModelID).displayName) from this device? You can download it again later."
    }
}

#Preview {
    ModelDownloadView()
        .environment(AppStore())
}
