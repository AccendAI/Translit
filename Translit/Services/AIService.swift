import Foundation
import MLXLLM
import MLXLMCommon
import MLXLMHFAPI
import MLXLMTokenizers

enum AIServiceError: LocalizedError {
    case emptyResponse
    case localInferenceFailed(message: String)

    var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "The model returned an empty response"
        case let .localInferenceFailed(message):
            return message
        }
    }
}

actor AIService {
    private let configuration: AppConfiguration

    init(configuration: AppConfiguration = AppConfiguration()) {
        self.configuration = configuration
    }

    func prepareModel(
        modelID: String? = nil,
        progressHandler: @escaping @Sendable (Double) -> Void
    ) async throws {
        let resolvedModelID = modelID ?? configuration.primaryModelID
        _ = try await LLMModelFactory.shared.loadContainer(
            from: HubClient.default,
            using: TokenizersLoader(),
            configuration: .init(id: resolvedModelID),
            progressHandler: { progress in
                progressHandler(progress.fractionCompleted)
            }
        )
    }

    func sendMessage(
        _ userMessage: String,
        targetLanguage: Language,
        modelID: String? = nil
    ) async throws -> MessageSendResult {
        try await sendMessage(
            userMessage,
            targetLanguage: targetLanguage,
            modelID: modelID ?? configuration.primaryModelID
        )
    }

    private func sendMessage(
        _ userMessage: String,
        targetLanguage: Language,
        modelID: String
    ) async throws -> MessageSendResult {
        let modelContainer = try await LLMModelFactory.shared.loadContainer(
            from: HubClient.default,
            using: TokenizersLoader(),
            configuration: .init(id: modelID)
        )

        let session = ChatSession(
            modelContainer,
            instructions: systemInstruction(for: targetLanguage),
            generateParameters: GenerateParameters(
                maxTokens: configuration.maxTokens,
                temperature: configuration.temperature
            )
        )

        let response: String
        do {
            response = try await session.respond(to: userMessage)
        } catch {
            throw mapError(error)
        }
        let sanitizedResponse = sanitizeResponse(response)

        guard !sanitizedResponse.isEmpty else {
            throw AIServiceError.emptyResponse
        }

        return MessageSendResult(content: sanitizedResponse, modelID: modelID)
    }

    private func systemInstruction(for language: Language) -> String {
        """
        You are a transliteration and translation assistant for \(language.name) (\(language.nativeName)).

        Your task:
        1. If the user types romanized or Latin text that sounds like \(language.name) words, convert it to the native \(language.name) script.
        2. If the user types in another language, translate it to \(language.name).

        Rules:
        - Return only the converted or translated text in \(language.name) script (\(language.nativeName)).
        - Do not include explanations, notes, the original text, labels, markdown, or quotation marks.
        - Do not reveal reasoning, thinking traces, or internal tags.
        - Preserve the meaning and tone of the original message.
        - If the input is already correctly written in \(language.nativeName), return the corrected native-script version only when needed.
        """
    }

    private func sanitizeResponse(_ response: String) -> String {
        var sanitized = response.trimmingCharacters(in: .whitespacesAndNewlines)
        sanitized = sanitized.replacingOccurrences(
            of: #"<\|channel\|>thought[\s\S]*?<channel\|>"#,
            with: "",
            options: .regularExpression
        )
        sanitized = sanitized.replacingOccurrences(of: "<|assistant|>", with: "")
        sanitized = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)

        if sanitized.hasPrefix("\"") && sanitized.hasSuffix("\"") && sanitized.count >= 2 {
            sanitized = String(sanitized.dropFirst().dropLast())
        }

        return sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func mapError(_ error: Error) -> AIServiceError {
        if let aiServiceError = error as? AIServiceError {
            return aiServiceError
        }

        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        return .localInferenceFailed(message: message)
    }
}
