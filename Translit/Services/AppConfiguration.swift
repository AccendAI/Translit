import Foundation

struct AppConfiguration {
    let primaryModelID: String
    let availableModels: [OnDeviceModel]
    let maxTokens: Int
    let temperature: Float

    nonisolated init(bundle: Bundle = .main, processInfo: ProcessInfo = .processInfo) {
        let environment = processInfo.environment
        let bundlePrimaryModelID = bundle.object(forInfoDictionaryKey: "TRANSLIT_MODEL_ID") as? String
        let envPrimaryModelID = environment["TRANSLIT_MODEL_ID"]
        let resolvedPrimaryModelID = envPrimaryModelID ?? bundlePrimaryModelID ?? AppConstants.defaultGemmaModelID
        let normalizedPrimaryModelID = resolvedPrimaryModelID.trimmingCharacters(in: .whitespacesAndNewlines)

        self.primaryModelID = normalizedPrimaryModelID
        self.availableModels = OnDeviceModel.availableModels(primaryModelID: normalizedPrimaryModelID)
        self.maxTokens = 256
        self.temperature = 0.2
    }
}
