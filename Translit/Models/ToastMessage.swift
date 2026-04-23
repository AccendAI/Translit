import Foundation

enum ToastStyle {
    case success
    case info
    case error
}

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let style: ToastStyle
    let title: String
    let subtitle: String?
}
