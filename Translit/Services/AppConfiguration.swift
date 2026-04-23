import Foundation

struct AppConfiguration {
    let primaryModelID: String
    let maxTokens: Int
    let temperature: Float

    nonisolated init(bundle: Bundle = .main, processInfo: ProcessInfo = .processInfo) {
        let environment = processInfo.environment
        let bundlePrimaryModelID = bundle.object(forInfoDictionaryKey: "TRANSLIT_MODEL_ID") as? String
        let envPrimaryModelID = environment["TRANSLIT_MODEL_ID"]
        let resolvedPrimaryModelID = envPrimaryModelID ?? bundlePrimaryModelID ?? AppConstants.defaultGemmaModelID

        self.primaryModelID = resolvedPrimaryModelID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.maxTokens = 256
        self.temperature = 0.2
    }
}
