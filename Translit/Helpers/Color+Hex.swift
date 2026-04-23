import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    static var appSystemBackground: Color {
        #if canImport(UIKit)
        Color(
            uiColor: UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 28.0 / 255.0, green: 28.0 / 255.0, blue: 30.0 / 255.0, alpha: 1.0)
                }

                return .systemBackground
            }
        )
        #elseif canImport(AppKit)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.white
        #endif
    }

    static var appGroupedBackground: Color {
        #if canImport(UIKit)
        Color(
            uiColor: UIColor { traits in
                if traits.userInterfaceStyle == .dark {
                    return UIColor(red: 28.0 / 255.0, green: 28.0 / 255.0, blue: 30.0 / 255.0, alpha: 1.0)
                }

                return .systemGroupedBackground
            }
        )
        #elseif canImport(AppKit)
        Color(nsColor: .underPageBackgroundColor)
        #else
        Color.white
        #endif
    }

    static var appSecondaryBackground: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondarySystemBackground)
        #elseif canImport(AppKit)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color.gray.opacity(0.12)
        #endif
    }
}
