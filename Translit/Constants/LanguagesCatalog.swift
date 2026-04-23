import Foundation

enum LanguagesCatalog {
    static let all: [Language] = [
        Language(code: "fa", name: "Persian (Farsi)", nativeName: "فارسی", script: .arabic),
        Language(code: "ar", name: "Arabic", nativeName: "العربية", script: .arabic),
        Language(code: "ur", name: "Urdu", nativeName: "اردو", script: .arabic),
        Language(code: "ps", name: "Pashto", nativeName: "پښتو", script: .arabic),
        Language(code: "ku", name: "Kurdish (Sorani)", nativeName: "کوردی", script: .arabic),
        Language(code: "sd", name: "Sindhi", nativeName: "سنڌي", script: .arabic),
        Language(code: "ug", name: "Uyghur", nativeName: "ئۇيغۇرچە", script: .arabic),

        Language(code: "he", name: "Hebrew", nativeName: "עברית", script: .hebrew),
        Language(code: "yi", name: "Yiddish", nativeName: "ייִדיש", script: .hebrew),

        Language(code: "ru", name: "Russian", nativeName: "Русский", script: .cyrillic),
        Language(code: "uk", name: "Ukrainian", nativeName: "Українська", script: .cyrillic),
        Language(code: "bg", name: "Bulgarian", nativeName: "Български", script: .cyrillic),
        Language(code: "sr", name: "Serbian", nativeName: "Српски", script: .cyrillic),
        Language(code: "mk", name: "Macedonian", nativeName: "Македонски", script: .cyrillic),
        Language(code: "be", name: "Belarusian", nativeName: "Беларуская", script: .cyrillic),
        Language(code: "kk", name: "Kazakh", nativeName: "Қазақша", script: .cyrillic),

        Language(code: "hi", name: "Hindi", nativeName: "हिन्दी", script: .devanagari),
        Language(code: "mr", name: "Marathi", nativeName: "मराठी", script: .devanagari),
        Language(code: "ne", name: "Nepali", nativeName: "नेपाली", script: .devanagari),
        Language(code: "sa", name: "Sanskrit", nativeName: "संस्कृतम्", script: .devanagari),

        Language(code: "bn", name: "Bengali", nativeName: "বাংলা", script: .bengali),
        Language(code: "as", name: "Assamese", nativeName: "অসমীয়া", script: .bengali),

        Language(code: "ta", name: "Tamil", nativeName: "தமிழ்", script: .tamil),

        Language(code: "th", name: "Thai", nativeName: "ไทย", script: .thai),

        Language(code: "ja", name: "Japanese", nativeName: "日本語", script: .japanese),

        Language(code: "ko", name: "Korean", nativeName: "한국어", script: .korean),

        Language(code: "zh-CN", name: "Chinese (Simplified)", nativeName: "简体中文", script: .chinese),
        Language(code: "zh-TW", name: "Chinese (Traditional)", nativeName: "繁體中文", script: .chinese),

        Language(code: "el", name: "Greek", nativeName: "Ελληνικά", script: .greek),

        Language(code: "hy", name: "Armenian", nativeName: "Հայերեն", script: .armenian),

        Language(code: "ka", name: "Georgian", nativeName: "ქართული", script: .georgian),
    ]

    static func filter(query: String) -> [Language] {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return all }

        return all.filter { language in
            language.name.lowercased().contains(normalized)
                || language.nativeName.lowercased().contains(normalized)
                || language.code.lowercased().contains(normalized)
        }
    }

    static func find(code: String) -> Language? {
        all.first { $0.code == code }
    }
}
