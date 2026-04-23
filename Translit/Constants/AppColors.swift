import SwiftUI

enum AppColors {
    // Ember brand colors.
    static let igniteFlame = Color(hex: 0xF46036)
    static let igniteHighlight = Color(hex: 0xFF8C40)
    static let igniteDeep = Color(hex: 0xE6471F)

    static let tint = igniteFlame
    static let destructive = Color.red

    // Shared semantic surface tokens.
    static let surfaceOverlay = Color.appSystemBackground.opacity(0.55)
    static let glassStroke = Color.white.opacity(0.07)
    static let inputStroke = Color.primary.opacity(0.07)

    static let userBubbleFill = igniteFlame.opacity(0.09)
    static let userBubbleStroke = igniteFlame.opacity(0.12)
    static let badgeBackground = igniteFlame.opacity(0.15)
    static let badgeForeground = igniteFlame
}
