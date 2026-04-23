import SwiftUI
import CoreText

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum AppTypography {
    static func heading(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        manrope(size: size, weight: weight)
    }

    static func ui(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        manrope(size: size, weight: weight)
    }

    private static func manrope(size: CGFloat, weight: Font.Weight) -> Font {
        let fontName = manropePostScriptName(for: weight)
        return customFont(named: fontName, size: size, fallback: .system(size: size, weight: weight))
    }

    private static func manropePostScriptName(for weight: Font.Weight) -> String {
        switch weight {
        case .ultraLight, .thin:
            return "Manrope-ExtraLight"
        case .light:
            return "Manrope-Light"
        case .bold:
            return "Manrope-Bold"
        case .heavy, .black:
            return "Manrope-Bold"
        case .semibold:
            return "Manrope-SemiBold"
        case .medium:
            return "Manrope-Medium"
        default:
            return "Manrope-Regular"
        }
    }

    private static func customFont(named name: String, size: CGFloat, fallback: Font) -> Font {
        guard isFontAvailable(named: name, size: size) else {
            return fallback
        }
        return .custom(name, size: size)
    }

    private static func isFontAvailable(named name: String, size: CGFloat) -> Bool {
        #if canImport(UIKit)
        UIFont(name: name, size: size) != nil
        #elseif canImport(AppKit)
        NSFont(name: name, size: size) != nil
        #else
        false
        #endif
    }
}

enum AppFontRegistrar {
    private static var didRegister = false

    static func registerBundledFonts() {
        guard !didRegister else {
            return
        }
        didRegister = true

        guard let resourceURL = Bundle.main.resourceURL,
              let enumerator = FileManager.default.enumerator(
                at: resourceURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
              ) else {
            return
        }

        for case let fileURL as URL in enumerator {
            let ext = fileURL.pathExtension.lowercased()
            guard ext == "ttf" || ext == "otf" else {
                continue
            }

            var registrationError: Unmanaged<CFError>?
            CTFontManagerRegisterFontsForURL(fileURL as CFURL, .process, &registrationError)
        }
    }
}
