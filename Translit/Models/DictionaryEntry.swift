import Foundation

enum DictionarySource: String, Codable {
    case history
    case chat
    case manual
}

struct DictionaryEntry: Identifiable, Codable, Equatable {
    let id: String
    let meaning: String
    let outputText: String
    let languageCode: String?
    let createdAt: TimeInterval
    let updatedAt: TimeInterval
    let source: DictionarySource

    private enum CodingKeys: String, CodingKey {
        case id
        case meaning
        case outputText
        case languageCode
        case createdAt
        case updatedAt
        case source
    }

    private enum LegacyCodingKeys: String, CodingKey {
        case label
        case text
    }

    nonisolated init(
        id: String,
        meaning: String,
        outputText: String,
        languageCode: String?,
        createdAt: TimeInterval,
        updatedAt: TimeInterval,
        source: DictionarySource
    ) {
        self.id = id
        self.meaning = meaning
        self.outputText = outputText
        self.languageCode = languageCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.source = source
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let legacyContainer = try decoder.container(keyedBy: LegacyCodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        meaning = try container.decodeIfPresent(String.self, forKey: .meaning)
            ?? legacyContainer.decodeIfPresent(String.self, forKey: .label)
            ?? ""
        outputText = try container.decodeIfPresent(String.self, forKey: .outputText)
            ?? legacyContainer.decodeIfPresent(String.self, forKey: .text)
            ?? ""
        languageCode = try container.decodeIfPresent(String.self, forKey: .languageCode)
        createdAt = try container.decode(TimeInterval.self, forKey: .createdAt)
        updatedAt = try container.decode(TimeInterval.self, forKey: .updatedAt)
        source = try container.decode(DictionarySource.self, forKey: .source)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(meaning, forKey: .meaning)
        try container.encode(outputText, forKey: .outputText)
        try container.encodeIfPresent(languageCode, forKey: .languageCode)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(source, forKey: .source)
    }
}

enum DictionaryAddStatus: Equatable {
    case added
    case duplicate
}

struct DictionaryAddResult: Equatable {
    let status: DictionaryAddStatus
    let entry: DictionaryEntry
    let entries: [DictionaryEntry]
}
