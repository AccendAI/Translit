import SwiftUI

enum LanguageSelectionMode {
    case onboarding
    case settings
}

struct LanguageSelectionView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let mode: LanguageSelectionMode

    @State private var searchQuery = ""
    @State private var isSelecting = false

    private var filteredLanguages: [Language] {
        LanguagesCatalog.filter(query: searchQuery)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(titleText)
                    .font(AppTypography.heading(size: 26, weight: .semibold))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitleText)
                    .font(AppTypography.ui(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 12)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search languages...", text: $searchQuery)
                    .font(AppTypography.ui(size: 13.5))
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .appGlassSurface(radius: AppTheme.Radius.bubble, stroke: AppColors.inputStroke)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            if filteredLanguages.isEmpty {
                EmptyStateView(
                    systemImage: "globe",
                    title: "No languages found",
                    subtitle: "No match for \"\(searchQuery)\""
                )
            } else {
                List(filteredLanguages) { language in
                    Button {
                        Task {
                            await handleSelect(language)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(language.name)
                                    .font(AppTypography.ui(size: 13.5, weight: .semibold))
                                    .foregroundStyle(.primary)
                                Text(language.nativeName)
                                    .font(AppTypography.ui(size: 13))
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(language.code.uppercased())
                                .font(AppTypography.ui(size: 10, weight: .medium))
                                .foregroundStyle(AppColors.badgeForeground)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(AppColors.badgeBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
                        }
                        .contentShape(Rectangle())
                    }
                    .disabled(isSelecting)
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.appSystemBackground.ignoresSafeArea())
        .toolbar {
            if mode == .settings {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var titleText: String {
        switch mode {
        case .onboarding:
            return "Choose Your Language"
        case .settings:
            return "Change Language"
        }
    }

    private var subtitleText: String {
        switch mode {
        case .onboarding:
            return "Select the language you want to type in"
        case .settings:
            return "Select the language you want to transliterate to"
        }
    }

    private func handleSelect(_ language: Language) async {
        guard !isSelecting else {
            return
        }

        isSelecting = true
        await store.setLanguage(language)

        if mode == .settings {
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        LanguageSelectionView(mode: .settings)
            .environment(AppStore())
    }
}
