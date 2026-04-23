import SwiftUI

struct HistoryTabView: View {
    @Environment(AppStore.self) private var store

    @State private var showClearAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if store.historyEntries.isEmpty {
                    EmptyStateView(
                        systemImage: "clock",
                        title: "No history yet",
                        subtitle: "Your translated text will appear here"
                    )
                    .padding(.horizontal, 24)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(store.historyEntries) { entry in
                                HistoryCardView(
                                    entry: entry,
                                    onCopy: {
                                        store.copyToClipboard(entry.outputText)
                                    },
                                    onSave: {
                                        Task {
                                            await store.saveHistoryResponseToDictionary(
                                                meaning: entry.meaning,
                                                outputText: entry.outputText
                                            )
                                        }
                                    }
                                )
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(Color.appGroupedBackground)
            .refreshable {
                await store.refreshHistory()
            }
            .task {
                await store.refreshHistory()
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !store.historyEntries.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button(role: .destructive) {
                            showClearAlert = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .alert("Clear History", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    Task {
                        await store.clearHistory()
                    }
                }
            } message: {
                Text("Are you sure you want to clear all history? This will also clear your current conversation.")
            }
        }
    }
}

#Preview {
    HistoryTabView()
        .environment(AppStore())
}
