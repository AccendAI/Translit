import SwiftUI

enum ThemeMode: String, Codable, CaseIterable {
    case system
    case light
    case dark

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

struct UserSettings: Codable, Equatable {
    var languageCode: String?
    var themeMode: ThemeMode
    var hasPreparedLocalModel: Bool
    var selectedModelID: String?
    var downloadedModelIDs: [String]

    static let `default` = UserSettings(
        languageCode: nil,
        themeMode: .system,
        hasPreparedLocalModel: false,
        selectedModelID: nil,
        downloadedModelIDs: []
    )
}
