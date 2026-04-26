import SwiftUI

enum RootTab: Hashable {
    case translate
    case history
    case dictionary
    case settings
}

struct AppRootView: View {
    @Environment(AppStore.self) private var store
    @State private var selectedTab: RootTab = .translate
    @State private var hasPresentedInitialModelSheet = false

    var body: some View {
        @Bindable var bindableStore = store

        Group {
            if !store.isReady {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.appSystemBackground)
            } else if !store.hasOnboarded {
                NavigationStack {
                    LanguageSelectionView(mode: .onboarding)
                }
            } else {
                TabView(selection: $selectedTab) {
                    TranslateTabView()
                        .tag(RootTab.translate)
                        .tabItem {
                            Label("Translate", systemImage: "character.book.closed")
                        }

                    HistoryTabView()
                        .tag(RootTab.history)
                        .tabItem {
                            Label("History", systemImage: "clock")
                        }

                    DictionaryTabView()
                        .tag(RootTab.dictionary)
                        .tabItem {
                            Label("Dictionary", systemImage: "bookmark")
                        }

                    SettingsTabView()
                        .tag(RootTab.settings)
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                }
                .tint(AppColors.tint)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(AppTheme.surfaceMaterial, for: .tabBar)
            }
        }
        .overlay(alignment: .top) {
            if let toast = store.toast {
                ToastOverlayView(toast: toast)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.spring(response: 0.33, dampingFraction: 0.9), value: store.toast?.id)
        .sheet(isPresented: $bindableStore.isModelManagementPresented) {
            NavigationStack {
                ModelDownloadView()
            }
            .environment(store)
            .presentationDetents([.medium, .large])
        }
        .task {
            presentInitialModelSheetIfNeeded()
        }
        .onChange(of: store.isReady) { _, _ in
            presentInitialModelSheetIfNeeded()
        }
        .onChange(of: store.hasOnboarded) { _, _ in
            presentInitialModelSheetIfNeeded()
        }
        .onChange(of: store.hasAnyDownloadedModels) { _, hasAnyDownloadedModels in
            if hasAnyDownloadedModels {
                hasPresentedInitialModelSheet = true
            }
        }
    }

    private func presentInitialModelSheetIfNeeded() {
        guard store.isReady else {
            return
        }

        guard store.hasOnboarded else {
            return
        }

        guard !store.hasAnyDownloadedModels else {
            return
        }

        guard !hasPresentedInitialModelSheet else {
            return
        }

        hasPresentedInitialModelSheet = true
        store.presentModelManagement()
    }
}

#Preview {
    AppRootView()
        .environment(AppStore())
}
