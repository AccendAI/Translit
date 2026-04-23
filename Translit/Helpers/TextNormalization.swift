import Foundation

enum TextNormalization {
    nonisolated static func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).precomposedStringWithCanonicalMapping
    }

    nonisolated static func createFallbackMeaning(from outputText: String) -> String {
        let trimmed = outputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "Untitled" }

        if trimmed.count <= AppConstants.defaultMeaningMaxLength {
            return trimmed
        }

        let prefix = trimmed.prefix(AppConstants.defaultMeaningMaxLength)
        return "\(prefix)…"
    }

    nonisolated static func sanitizeMeaning(_ meaning: String?, fallbackOutputText: String) -> String {
        let cleaned = meaning?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if cleaned.isEmpty {
            return createFallbackMeaning(from: fallbackOutputText)
        }

        return cleaned
    }
}
