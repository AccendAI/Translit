import Foundation

actor SettingsStorageService {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSettings() -> UserSettings {
        let languageCode = defaults.string(forKey: AppConstants.userLanguageKey)
        let themeRawValue = defaults.string(forKey: AppConstants.userThemeKey)
        let themeMode = ThemeMode(rawValue: themeRawValue ?? "") ?? .system
        let hasPreparedLocalModel = defaults.bool(forKey: AppConstants.preparedLocalModelKey)
        let selectedModelID = defaults.string(forKey: AppConstants.selectedModelIDKey)
        var downloadedModelIDs = defaults.stringArray(forKey: AppConstants.downloadedModelIDsKey) ?? []

        if hasPreparedLocalModel && downloadedModelIDs.isEmpty {
            downloadedModelIDs = [selectedModelID ?? AppConstants.defaultGemmaModelID]
        }

        return UserSettings(
            languageCode: languageCode,
            themeMode: themeMode,
            hasPreparedLocalModel: hasPreparedLocalModel || !downloadedModelIDs.isEmpty,
            selectedModelID: selectedModelID,
            downloadedModelIDs: downloadedModelIDs
        )
    }

    func saveLanguageCode(_ languageCode: String) {
        defaults.set(languageCode, forKey: AppConstants.userLanguageKey)
    }

    func saveThemeMode(_ mode: ThemeMode) {
        defaults.set(mode.rawValue, forKey: AppConstants.userThemeKey)
    }

    func savePreparedLocalModel(_ isPrepared: Bool) {
        defaults.set(isPrepared, forKey: AppConstants.preparedLocalModelKey)
    }

    func saveSelectedModelID(_ modelID: String?) {
        defaults.set(modelID, forKey: AppConstants.selectedModelIDKey)
    }

    func saveDownloadedModelIDs(_ modelIDs: [String]) {
        defaults.set(modelIDs, forKey: AppConstants.downloadedModelIDsKey)
        defaults.set(!modelIDs.isEmpty, forKey: AppConstants.preparedLocalModelKey)
    }

    func hasCompletedOnboarding() -> Bool {
        defaults.string(forKey: AppConstants.userLanguageKey) != nil
    }
}
