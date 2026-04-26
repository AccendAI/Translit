import Foundation

struct OnDeviceModel: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let displayName: String
    let subtitle: String
    let storageDescription: String
    let isRecommended: Bool

    init(
        id: String,
        displayName: String,
        subtitle: String,
        storageDescription: String,
        isRecommended: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.subtitle = subtitle
        self.storageDescription = storageDescription
        self.isRecommended = isRecommended
    }

    static func availableModels(primaryModelID: String) -> [OnDeviceModel] {
        [details(for: primaryModelID, isRecommended: true)]
    }

    static func details(for modelID: String, isRecommended: Bool = false) -> OnDeviceModel {
        let normalized = modelID.lowercased()

        if normalized.contains("gemma-4-e2b") {
            return OnDeviceModel(
                id: modelID,
                displayName: "Gemma 4 E2B",
                subtitle: "Balanced quality and speed for everyday on-device translation",
                storageDescription: "~2-4 GB download",
                isRecommended: isRecommended
            )
        }

        if normalized.contains("gemma-4-e4b") {
            return OnDeviceModel(
                id: modelID,
                displayName: "Gemma 4 E4B",
                subtitle: "Higher quality responses with a larger on-device footprint",
                storageDescription: "~4-6 GB download",
                isRecommended: isRecommended
            )
        }

        if normalized.contains("gemma-3n-e2b") {
            return OnDeviceModel(
                id: modelID,
                displayName: "Gemma 3n E2B",
                subtitle: "Compact local model tuned for lighter memory usage",
                storageDescription: "~2-4 GB download",
                isRecommended: isRecommended
            )
        }

        return OnDeviceModel(
            id: modelID,
            displayName: modelID.replacingOccurrences(of: "mlx-community/", with: ""),
            subtitle: "Available for on-device translation after download",
            storageDescription: "Download size depends on the model variant",
            isRecommended: isRecommended
        )
    }
}
