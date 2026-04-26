import SwiftUI

struct SettingsTabView: View {
    @Environment(AppStore.self) private var store

    @State private var showLanguageSelection = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    sectionTitle("LANGUAGE")

                    SettingRowView(
                        systemImage: "globe",
                        label: "Target Language",
                        value: selectedLanguageText
                    ) {
                        showLanguageSelection = true
                    }

                    sectionTitle("MODEL")

                    SettingRowView(
                        systemImage: "cpu",
                        label: "On-Device Model",
                        value: store.localModelStatusText
                    ) {}
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
            .background(Color.appGroupedBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showLanguageSelection) {
            NavigationStack {
                LanguageSelectionView(mode: .settings)
            }
            .environment(store)
            .presentationDetents([.large])
        }
    }

    private var selectedLanguageText: String {
        guard let language = store.selectedLanguage else {
            return "Not selected"
        }

        return "\(language.name) (\(language.nativeName))"
    }

    private func sectionTitle(_ value: String) -> some View {
        Text(value)
            .font(AppTypography.ui(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
    }
}

#Preview {
    SettingsTabView()
        .environment(AppStore())
}
