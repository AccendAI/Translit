import Foundation
import Observation

@MainActor
@Observable
final class AppStore {
    private let settingsStorage: SettingsStorageService
    private let chatStorage: ChatStorageService
    private let dictionaryStorage: DictionaryStorageService
    private let aiService: AIService
    private let modelStorage: ModelStorageService
    private let configuration: AppConfiguration

    var isReady = false
    var selectedLanguage: Language?
    var themeMode: ThemeMode = .system
    var currentConversation: ChatHistory = []
    var historyEntries: [HistoryEntry] = []
    var dictionaryEntries: [DictionaryEntry] = []
    var isSendingMessage = false
    var toast: ToastMessage?
    var isModelManagementPresented = false
    var availableModels: [OnDeviceModel] = []
    var selectedModelID: String
    var downloadedModelIDs: [String] = []
    var isPreparingLocalModel = false
    var activeModelOperationID: String?
    var deletingModelID: String?
    var modelPreparationErrorMessage: String?
    var modelDownloadProgress: Double = 0.0

    var hasOnboarded: Bool {
        selectedLanguage != nil
    }

    var hasAnyDownloadedModels: Bool {
        !downloadedModelIDs.isEmpty
    }

    var hasPreparedLocalModel: Bool {
        downloadedModelIDs.contains(selectedModelID)
    }

    var selectedModel: OnDeviceModel {
        availableModels.first(where: { $0.id == selectedModelID }) ?? OnDeviceModel.details(for: selectedModelID)
    }

    var localModelStatusText: String {
        hasAnyDownloadedModels ? selectedModel.displayName : "No model downloaded"
    }

    init(
        settingsStorage: SettingsStorageService = SettingsStorageService(),
        chatStorage: ChatStorageService = ChatStorageService(),
        dictionaryStorage: DictionaryStorageService = DictionaryStorageService(),
        configuration: AppConfiguration = AppConfiguration(),
        aiService: AIService? = nil,
        modelStorage: ModelStorageService = ModelStorageService()
    ) {
        self.settingsStorage = settingsStorage
        self.chatStorage = chatStorage
        self.dictionaryStorage = dictionaryStorage
        self.configuration = configuration
        self.aiService = aiService ?? AIService(configuration: configuration)
        self.modelStorage = modelStorage
        self.availableModels = configuration.availableModels
        self.selectedModelID = configuration.primaryModelID

        Task {
            await initialize()
        }
    }

    func initialize() async {
        async let settings = settingsStorage.loadSettings()
        async let conversation = chatStorage.loadCurrentConversation()
        async let history = chatStorage.loadChatHistory()
        async let entries = dictionaryStorage.loadEntries()

        let resolvedSettings = await settings
        let resolvedConversation = await conversation
        let resolvedHistory = await history
        let resolvedEntries = await entries

        selectedLanguage = resolvedSettings.languageCode.flatMap { LanguagesCatalog.find(code: $0) }
        themeMode = resolvedSettings.themeMode
        currentConversation = resolvedConversation
        historyEntries = makeHistoryEntries(from: resolvedHistory)
        dictionaryEntries = resolvedEntries
        let normalizedDownloadedModelIDs = normalizedDownloadedModelIDs(from: resolvedSettings.downloadedModelIDs)
        downloadedModelIDs = normalizedDownloadedModelIDs
        selectedModelID = resolvedSelectedModelID(
            preferredModelID: resolvedSettings.selectedModelID,
            downloadedModelIDs: normalizedDownloadedModelIDs
        )

        if resolvedSettings.selectedModelID != selectedModelID {
            await settingsStorage.saveSelectedModelID(selectedModelID)
        }

        if resolvedSettings.downloadedModelIDs != normalizedDownloadedModelIDs {
            await settingsStorage.saveDownloadedModelIDs(normalizedDownloadedModelIDs)
        }

        isReady = true
    }

    func setLanguage(_ language: Language) async {
        await settingsStorage.saveLanguageCode(language.code)
        selectedLanguage = language
    }

    func setThemeMode(_ mode: ThemeMode) async {
        await settingsStorage.saveThemeMode(mode)
        themeMode = mode
    }

    func presentModelManagement() {
        isModelManagementPresented = true
    }

    func dismissModelManagement() {
        isModelManagementPresented = false
    }

    func isModelDownloaded(_ modelID: String) -> Bool {
        downloadedModelIDs.contains(modelID)
    }

    func isPreparingModel(_ modelID: String) -> Bool {
        isPreparingLocalModel && activeModelOperationID == modelID
    }

    func isDeletingModel(_ modelID: String) -> Bool {
        deletingModelID == modelID
    }

    func selectModel(_ modelID: String) async {
        guard availableModels.contains(where: { $0.id == modelID }) else {
            return
        }

        guard isModelDownloaded(modelID) else {
            return
        }

        selectedModelID = modelID
        await settingsStorage.saveSelectedModelID(modelID)
        queueToast(style: .success, title: "Model selected", subtitle: "\(selectedModel.displayName) is ready to use")
    }

    func prepareLocalModel(modelID: String? = nil) async {
        let targetModelID = modelID ?? selectedModelID

        guard availableModels.contains(where: { $0.id == targetModelID }) else {
            return
        }

        guard !isPreparingLocalModel else {
            return
        }

        guard !isModelDownloaded(targetModelID) else {
            return
        }

        isPreparingLocalModel = true
        activeModelOperationID = targetModelID
        modelPreparationErrorMessage = nil
        modelDownloadProgress = 0.0

        do {
            try await aiService.prepareModel(modelID: targetModelID) { [weak self] progress in
                Task { @MainActor [weak self] in
                    self?.modelDownloadProgress = progress
                }
            }
            selectedModelID = targetModelID
            if !downloadedModelIDs.contains(targetModelID) {
                downloadedModelIDs.append(targetModelID)
            }
            await persistModelState()
            queueToast(
                style: .success,
                title: "Model ready",
                subtitle: "\(selectedModel.displayName) is ready for on-device translation"
            )
        } catch let error as AIServiceError {
            modelPreparationErrorMessage = error.errorDescription
            queueToast(style: .error, title: "Model download failed", subtitle: error.errorDescription)
        } catch {
            let subtitle = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            modelPreparationErrorMessage = subtitle
            queueToast(style: .error, title: "Model download failed", subtitle: subtitle)
        }

        isPreparingLocalModel = false
        activeModelOperationID = nil
        modelDownloadProgress = 0.0
    }

    func deleteDownloadedModel(_ modelID: String) async {
        guard isModelDownloaded(modelID) else {
            return
        }

        guard deletingModelID == nil else {
            return
        }

        deletingModelID = modelID
        modelPreparationErrorMessage = nil

        do {
            try await modelStorage.deleteModel(id: modelID)
            downloadedModelIDs.removeAll { $0 == modelID }

            if selectedModelID == modelID {
                selectedModelID = resolvedSelectedModelID(
                    preferredModelID: nil,
                    downloadedModelIDs: downloadedModelIDs
                )
            }

            await persistModelState()
            queueToast(
                style: .success,
                title: "Model deleted",
                subtitle: "\(OnDeviceModel.details(for: modelID).displayName) was removed from this device"
            )
        } catch {
            let subtitle = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            modelPreparationErrorMessage = subtitle
            queueToast(style: .error, title: "Failed to delete model", subtitle: subtitle)
        }

        deletingModelID = nil
    }

    func sendMessage(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        guard hasPreparedLocalModel else {
            queueToast(
                style: .info,
                title: "Download the model first",
                subtitle: "Prepare the on-device model before sending your first translation"
            )
            return
        }

        guard let language = selectedLanguage else {
            queueToast(style: .error, title: "Target language required", subtitle: "Choose a language in Settings")
            return
        }

        guard !isSendingMessage else {
            return
        }

        let userMessage = ChatMessage.user(trimmed)
        currentConversation.append(userMessage)
        await persistConversation()
        isSendingMessage = true

        do {
            let response = try await aiService.sendMessage(
                trimmed,
                targetLanguage: language,
                modelID: selectedModelID
            )
            selectedModelID = response.modelID ?? selectedModelID
            await settingsStorage.saveSelectedModelID(selectedModelID)
            currentConversation.append(ChatMessage.assistant(response.content))
            await persistConversation()
            copyToClipboard(response.content, title: "Response copied to clipboard")
        } catch let error as AIServiceError {
            await handleSendFailure(error)
        } catch {
            await handleUnexpectedSendFailure(error)
        }

        isSendingMessage = false
    }

    func startNewConversation() async {
        currentConversation = []
        await chatStorage.startNewConversation()
    }

    func clearHistory() async {
        await chatStorage.clearChatHistory()
        currentConversation = []
        historyEntries = []
        queueToast(style: .success, title: "History cleared", subtitle: nil)
    }

    func refreshHistory() async {
        let history = await chatStorage.loadChatHistory()
        historyEntries = makeHistoryEntries(from: history)
    }

    func copyToClipboard(_ text: String, title: String = "Copied to clipboard") {
        ClipboardHelper.copy(text)
        let subtitle = text.count > 50 ? "\(text.prefix(50))..." : text
        queueToast(style: .success, title: title, subtitle: subtitle)
    }

    func showToast(style: ToastStyle, title: String, subtitle: String? = nil) {
        queueToast(style: style, title: title, subtitle: subtitle)
    }

    func saveHistoryResponseToDictionary(meaning: String?, outputText: String) async {
        let result = await dictionaryStorage.addEntry(
            meaning: meaning,
            outputText: outputText,
            languageCode: selectedLanguage?.code,
            source: .history
        )

        dictionaryEntries = result.entries

        if result.status == .duplicate {
            queueToast(style: .info, title: "Already saved", subtitle: nil)
        } else {
            queueToast(style: .success, title: "Saved to Dictionary", subtitle: nil)
        }
    }

    func addManualDictionaryEntry(meaning: String?, outputText: String) async -> DictionaryAddResult? {
        let result = await dictionaryStorage.addEntry(
            meaning: meaning,
            outputText: outputText,
            languageCode: selectedLanguage?.code,
            source: .manual
        )

        dictionaryEntries = result.entries

        if result.status == .duplicate {
            queueToast(style: .info, title: "Already saved", subtitle: nil)
        } else {
            queueToast(style: .success, title: "Saved to Dictionary", subtitle: nil)
        }

        return result
    }

    func updateDictionaryEntry(id: String, meaning: String?, outputText: String?) async {
        dictionaryEntries = await dictionaryStorage.updateEntry(id: id, meaning: meaning, outputText: outputText)
        queueToast(style: .success, title: "Entry updated", subtitle: nil)
    }

    func deleteDictionaryEntry(id: String) async {
        dictionaryEntries = await dictionaryStorage.deleteEntry(id: id)
        queueToast(style: .success, title: "Entry deleted", subtitle: nil)
    }

    func dictionaryEntry(id: String) -> DictionaryEntry? {
        dictionaryEntries.first { $0.id == id }
    }

    private func persistConversation() async {
        await chatStorage.saveCurrentConversation(currentConversation)
        await refreshHistory()
    }

    private func makeHistoryEntries(from history: ChatHistory) -> [HistoryEntry] {
        var entries: [HistoryEntry] = []
        var pendingUserMessage: ChatMessage?

        for message in history.sorted(by: { $0.timestamp < $1.timestamp }) {
            switch message.role {
            case .user:
                pendingUserMessage = message
            case .assistant:
                entries.append(
                    HistoryEntry(
                        id: message.id,
                        meaning: pendingUserMessage?.content,
                        outputText: message.content,
                        timestamp: message.timestamp
                    )
                )
                pendingUserMessage = nil
            }
        }

        return entries.sorted(by: { $0.timestamp > $1.timestamp })
    }

    private func handleSendFailure(_ error: AIServiceError) async {
        currentConversation.append(ChatMessage.assistantError())
        await persistConversation()
        queueToast(style: .error, title: "On-device model unavailable", subtitle: error.errorDescription)
    }

    private func handleUnexpectedSendFailure(_ error: Error) async {
        currentConversation.append(ChatMessage.assistantError())
        await persistConversation()
        let subtitle = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        queueToast(style: .error, title: "Failed to get AI response", subtitle: subtitle)
    }

    private func persistModelState() async {
        await settingsStorage.saveSelectedModelID(selectedModelID)
        await settingsStorage.saveDownloadedModelIDs(downloadedModelIDs)
    }

    private func normalizedDownloadedModelIDs(from modelIDs: [String]) -> [String] {
        let supportedModelIDs = Set(availableModels.map(\.id))
        var seen: Set<String> = []

        return modelIDs.filter { modelID in
            guard supportedModelIDs.contains(modelID) else {
                return false
            }

            return seen.insert(modelID).inserted
        }
    }

    private func resolvedSelectedModelID(
        preferredModelID: String?,
        downloadedModelIDs: [String]
    ) -> String {
        if let preferredModelID,
           availableModels.contains(where: { $0.id == preferredModelID }) {
            return preferredModelID
        }

        if let downloadedModelID = downloadedModelIDs.first {
            return downloadedModelID
        }

        return configuration.primaryModelID
    }

    private func queueToast(style: ToastStyle, title: String, subtitle: String?) {
        let newToast = ToastMessage(style: style, title: title, subtitle: subtitle)
        toast = newToast

        Task {
            try? await Task.sleep(for: .seconds(2))
            guard toast?.id == newToast.id else {
                return
            }
            toast = nil
        }
    }
}
