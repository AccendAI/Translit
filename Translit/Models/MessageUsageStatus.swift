import Foundation

struct MessageSendResult {
    let content: String
    let modelID: String?

    nonisolated init(content: String, modelID: String? = nil) {
        self.content = content
        self.modelID = modelID
    }
}
