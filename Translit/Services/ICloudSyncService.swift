import Foundation

actor ICloudSyncService {
    init() {}

    func save(_ entries: [DictionaryEntry]) {
        return
    }

    func load() -> [DictionaryEntry] {
        []
    }

    nonisolated func startObserving(onChange: @escaping @Sendable () -> Void) {
        _ = onChange
    }
}
