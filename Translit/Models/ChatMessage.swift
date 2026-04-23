import Foundation

enum MessageRole: String, Codable {
    case user
    case assistant
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: String
    let role: MessageRole
    let content: String
    let timestamp: TimeInterval

    static func user(_ content: String, now: Date = Date()) -> ChatMessage {
        ChatMessage(id: "user-\(Int(now.timeIntervalSince1970 * 1000))", role: .user, content: content, timestamp: now.timeIntervalSince1970)
    }

    static func assistant(_ content: String, now: Date = Date()) -> ChatMessage {
        ChatMessage(id: "assistant-\(Int(now.timeIntervalSince1970 * 1000))", role: .assistant, content: content, timestamp: now.timeIntervalSince1970)
    }

    static func assistantError(now: Date = Date()) -> ChatMessage {
        ChatMessage(id: "error-\(Int(now.timeIntervalSince1970 * 1000))", role: .assistant, content: "Sorry, I encountered an error. Please try again.", timestamp: now.timeIntervalSince1970)
    }
}

typealias ChatHistory = [ChatMessage]
