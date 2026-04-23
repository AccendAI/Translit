import Foundation

actor DictionaryStorageService {
    private let defaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadEntries() -> [DictionaryEntry] {
        guard let data = defaults.data(forKey: AppConstants.dictionaryKey) else {
            return []
        }

        do {
            return try decoder.decode([DictionaryEntry].self, from: data)
        } catch {
            return []
        }
    }

    func addEntry(meaning: String?, outputText: String, languageCode: String?, source: DictionarySource) -> DictionaryAddResult {
        var entries = loadEntries()
        let normalizedOutputText = TextNormalization.normalize(outputText)

        if let existing = entries.first(where: { $0.languageCode == languageCode && TextNormalization.normalize($0.outputText) == normalizedOutputText }) {
            return DictionaryAddResult(status: .duplicate, entry: existing, entries: entries)
        }

        let now = Date().timeIntervalSince1970
        let entry = DictionaryEntry(
            id: "dict-\(Int(now * 1000))",
            meaning: TextNormalization.sanitizeMeaning(meaning, fallbackOutputText: outputText),
            outputText: outputText.trimmingCharacters(in: .whitespacesAndNewlines),
            languageCode: languageCode,
            createdAt: now,
            updatedAt: now,
            source: source
        )

        entries.insert(entry, at: 0)
        persist(entries)

        return DictionaryAddResult(status: .added, entry: entry, entries: entries)
    }

    func updateEntry(id: String, meaning: String?, outputText: String?) -> [DictionaryEntry] {
        var entries = loadEntries()
        guard let index = entries.firstIndex(where: { $0.id == id }) else {
            return entries
        }

        let current = entries[index]
        let updatedOutputText = outputText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? current.outputText
        let updatedMeaning = meaning.map { TextNormalization.sanitizeMeaning($0, fallbackOutputText: updatedOutputText) } ?? current.meaning
        let now = Date().timeIntervalSince1970

        let updated = DictionaryEntry(
            id: current.id,
            meaning: updatedMeaning,
            outputText: updatedOutputText,
            languageCode: current.languageCode,
            createdAt: current.createdAt,
            updatedAt: now,
            source: current.source
        )

        entries[index] = updated
        persist(entries)

        return entries
    }

    func deleteEntry(id: String) -> [DictionaryEntry] {
        let entries = loadEntries().filter { $0.id != id }
        persist(entries)
        return entries
    }

    private func persist(_ entries: [DictionaryEntry]) {
        do {
            let data = try encoder.encode(entries)
            defaults.set(data, forKey: AppConstants.dictionaryKey)
        } catch {
            return
        }
    }
}
