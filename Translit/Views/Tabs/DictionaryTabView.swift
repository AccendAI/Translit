import SwiftUI

private enum DictionaryFilterMode: String, CaseIterable, Identifiable {
    case current
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .current:
            return "Current"
        case .all:
            return "All"
        }
    }
}

private enum DictionaryEditorRoute: Identifiable {
    case create
    case edit(id: String)

    var id: String {
        switch self {
        case .create:
            return "create"
        case let .edit(id):
            return "edit-\(id)"
        }
    }

    var entryID: String? {
        switch self {
        case .create:
            return nil
        case let .edit(id):
            return id
        }
    }
}

struct DictionaryTabView: View {
    @Environment(AppStore.self) private var store

    @State private var searchQuery = ""
    @State private var filterMode: DictionaryFilterMode = .all
    @State private var editorRoute: DictionaryEditorRoute?
    @State private var hasInitializedFilter = false

    private var filteredEntries: [DictionaryEntry] {
        var entries = store.dictionaryEntries

        if filterMode == .current, let languageCode = store.selectedLanguage?.code {
            entries = entries.filter { $0.languageCode == languageCode }
        }

        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            entries = entries.filter {
                $0.meaning.lowercased().contains(query)
                    || $0.outputText.lowercased().contains(query)
            }
        }

        return entries.sorted(by: { $0.updatedAt > $1.updatedAt })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                controls

                if filteredEntries.isEmpty {
                    EmptyStateView(
                        systemImage: "bookmark",
                        title: "No saved phrases yet",
                        subtitle: "Save translation pairs from History to build your dictionary"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredEntries) { entry in
                                DictionaryCardView(
                                    entry: entry,
                                    onTap: {
                                        editorRoute = .edit(id: entry.id)
                                    },
                                    onCopy: {
                                        store.copyToClipboard(entry.outputText)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
            .padding(.top, 8)
            .background(Color.appGroupedBackground)
            .navigationTitle("Dictionary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editorRoute = .create
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .onAppear {
                if !hasInitializedFilter {
                    if store.selectedLanguage != nil {
                        filterMode = .current
                    } else {
                        filterMode = .all
                    }
                    hasInitializedFilter = true
                }
            }
            .onChange(of: store.selectedLanguage?.code) { _, code in
                if code == nil {
                    filterMode = .all
                }
            }
            .sheet(item: $editorRoute) { route in
                NavigationStack {
                    DictionaryEntryView(entryID: route.entryID)
                }
                .environment(store)
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search meanings or saved text...", text: $searchQuery)
                    .font(AppTypography.ui(size: 13.5))
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .appGlassSurface(radius: AppTheme.Radius.bubble, stroke: AppColors.inputStroke)

            Picker("Filter", selection: $filterMode) {
                ForEach(DictionaryFilterMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .tint(AppColors.tint)
            .disabled(store.selectedLanguage == nil)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    DictionaryTabView()
        .environment(AppStore())
}
