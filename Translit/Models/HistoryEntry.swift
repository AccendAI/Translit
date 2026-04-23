import Foundation

struct HistoryEntry: Identifiable, Equatable {
    let id: String
    let meaning: String?
    let outputText: String
    let timestamp: TimeInterval
}
