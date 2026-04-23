import SwiftUI

enum AppTheme {
    static let surfaceMaterial: Material = .ultraThinMaterial

    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 10
        static let bubble: CGFloat = 14
        static let card: CGFloat = 16
    }

    enum Spacing {
        static let screenPadding: CGFloat = 16
        static let cardPadding: CGFloat = 16
        static let stack: CGFloat = 12
    }
}
