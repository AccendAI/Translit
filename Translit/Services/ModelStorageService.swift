import Foundation
import MLXLMCommon
import MLXLMHFAPI

actor ModelStorageService {
    private let fileManager: FileManager
    private let hubClient: HubClient

    init(
        fileManager: FileManager = .default,
        hubClient: HubClient = .default
    ) {
        self.fileManager = fileManager
        self.hubClient = hubClient
    }

    func deleteModel(id: String) throws {
        guard let repoID = Repo.ID(rawValue: id) else {
            throw ModelStorageError.invalidModelIdentifier
        }

        let cache = hubClient.cache
        let paths = [
            cache.repoDirectory(repo: repoID, kind: .model),
            cache.locksDirectory(repo: repoID, kind: .model),
            cache.metadataDirectory(repo: repoID, kind: .model)
        ]

        for path in paths where fileManager.fileExists(atPath: path.path) {
            try fileManager.removeItem(at: path)
        }
    }
}

enum ModelStorageError: LocalizedError {
    case invalidModelIdentifier

    var errorDescription: String? {
        switch self {
        case .invalidModelIdentifier:
            return "The selected model identifier is invalid"
        }
    }
}
