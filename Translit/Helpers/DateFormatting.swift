import Foundation

enum DateFormatting {
    static func relativeDateString(timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let now = Date()
        let diffDays = Calendar.current.dateComponents([.day], from: date.startOfDay, to: now.startOfDay).day ?? 0

        let timeText = date.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute())

        if diffDays == 0 {
            return "Today at \(timeText)"
        }

        if diffDays == 1 {
            return "Yesterday at \(timeText)"
        }

        return date.formatted(.dateTime.month(.abbreviated).day().hour(.defaultDigits(amPM: .abbreviated)).minute())
    }
}

private extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
