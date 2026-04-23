import Foundation

actor ChatStorageService {
    private let defaults: UserDefaults
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadChatHistory() -> ChatHistory {
        guard let data = defaults.data(forKey: AppConstants.chatHistoryKey) else {
            return []
        }

        do {
            return try decoder.decode(ChatHistory.self, from: data)
        } catch {
            return []
        }
    }

    func loadCurrentConversation() -> ChatHistory {
        let history = loadChatHistory()
        let startTimestamp = defaults.double(forKey: AppConstants.conversationStartKey)

        guard startTimestamp > 0 else {
            return history
        }

        return history.filter { $0.timestamp >= startTimestamp }
    }

    func saveCurrentConversation(_ messages: ChatHistory) {
        let existingHistory = loadChatHistory()
        let startTimestamp = defaults.double(forKey: AppConstants.conversationStartKey)

        let olderMessages: ChatHistory
        if startTimestamp > 0 {
            olderMessages = existingHistory.filter { $0.timestamp < startTimestamp }
        } else {
            olderMessages = []
        }

        let merged = olderMessages + messages
        do {
            let data = try encoder.encode(merged)
            defaults.set(data, forKey: AppConstants.chatHistoryKey)
        } catch {
            return
        }
    }

    func startNewConversation() {
        defaults.set(Date().timeIntervalSince1970, forKey: AppConstants.conversationStartKey)
    }

    func clearChatHistory() {
        defaults.removeObject(forKey: AppConstants.chatHistoryKey)
        defaults.removeObject(forKey: AppConstants.conversationStartKey)
    }
}
