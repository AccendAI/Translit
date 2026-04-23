import SwiftUI

@main
struct TranslitApp: App {
    @State private var store = AppStore()

    init() {
        AppFontRegistrar.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(store)
                .preferredColorScheme(store.themeMode.preferredColorScheme)
        }
    }
}
