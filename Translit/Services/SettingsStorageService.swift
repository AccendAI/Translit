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

        return UserSettings(
            languageCode: languageCode,
            themeMode: themeMode,
            hasPreparedLocalModel: hasPreparedLocalModel
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

    func hasCompletedOnboarding() -> Bool {
        defaults.string(forKey: AppConstants.userLanguageKey) != nil
    }
}
