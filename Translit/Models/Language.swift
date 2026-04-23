import Foundation

enum LanguageScript: String, Codable, CaseIterable {
    case arabic
    case hebrew
    case cyrillic
    case devanagari
    case bengali
    case tamil
    case thai
    case japanese
    case korean
    case chinese
    case greek
    case armenian
    case georgian
}

struct Language: Identifiable, Codable, Equatable, Hashable {
    let code: String
    let name: String
    let nativeName: String
    let script: LanguageScript

    var id: String { code }
}
