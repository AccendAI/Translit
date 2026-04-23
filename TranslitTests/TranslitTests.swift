import Foundation
import Testing
@testable import Translit

struct TranslitTests {
    @Test
    func languageFilteringMatchesNameNativeNameAndCode() {
        let byName = LanguagesCatalog.filter(query: "Persian")
        #expect(byName.contains(where: { $0.code == "fa" }))

        let byNativeName = LanguagesCatalog.filter(query: "فار")
        #expect(byNativeName.contains(where: { $0.code == "fa" }))

        let byCode = LanguagesCatalog.filter(query: "zh-cn")
        #expect(byCode.contains(where: { $0.code == "zh-CN" }))
    }

    @Test
    func textNormalizationCreatesFallbackLabel() {
        let label = TextNormalization.sanitizeLabel("   ", fallbackText: "This is a fallback sentence")
        #expect(label == "This is a fallback sentence")

        let longLabel = TextNormalization.createDefaultLabel(from: String(repeating: "a", count: 40))
        #expect(longLabel.hasSuffix("…"))
        #expect(longLabel.count == AppConstants.defaultLabelMaxLength + 1)
    }

    @Test
    func dictionaryStorageDeduplicatesNormalizedTextPerLanguage() async {
        let suiteName = "TranslitTests-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            Issue.record("Failed to create UserDefaults suite")
            return
        }
        defaults.removePersistentDomain(forName: suiteName)

        let service = DictionaryStorageService(defaults: defaults)

        let first = await service.addEntry(label: nil, text: "سلام", languageCode: "fa", source: .manual)
        let second = await service.addEntry(label: nil, text: "سلام ", languageCode: "fa", source: .manual)

        #expect(first.status == .added)
        #expect(second.status == .duplicate)
        #expect(second.entries.count == 1)

        defaults.removePersistentDomain(forName: suiteName)
    }

    @Test
    func chatStoragePreservesOlderHistoryWhenSavingCurrentConversation() async {
        let suiteName = "TranslitTests-\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            Issue.record("Failed to create UserDefaults suite")
            return
        }
        defaults.removePersistentDomain(forName: suiteName)

        let service = ChatStorageService(defaults: defaults)

        let oldMessage = ChatMessage(id: "assistant-1", role: .assistant, content: "old", timestamp: Date().addingTimeInterval(-3600).timeIntervalSince1970)
        await service.saveCurrentConversation([oldMessage])

        await service.startNewConversation()

        let newMessage = ChatMessage(id: "assistant-2", role: .assistant, content: "new", timestamp: Date().timeIntervalSince1970)
        await service.saveCurrentConversation([newMessage])

        let history = await service.loadChatHistory()
        #expect(history.count == 2)
        #expect(history.contains(where: { $0.id == "assistant-1" }))
        #expect(history.contains(where: { $0.id == "assistant-2" }))

        defaults.removePersistentDomain(forName: suiteName)
    }
}
