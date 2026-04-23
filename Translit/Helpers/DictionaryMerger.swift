import Foundation

enum DictionaryMerger {
    static func merge(local: [DictionaryEntry], remote: [DictionaryEntry]) -> [DictionaryEntry] {
        var entriesById: [String: DictionaryEntry] = [:]

        for entry in local {
            entriesById[entry.id] = entry
        }

        for entry in remote {
            if let existing = entriesById[entry.id] {
                if entry.updatedAt > existing.updatedAt {
                    entriesById[entry.id] = entry
                }
            } else {
                entriesById[entry.id] = entry
            }
        }

        return entriesById.values.sorted { $0.createdAt > $1.createdAt }
    }
}
