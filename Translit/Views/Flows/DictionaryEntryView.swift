import SwiftUI

struct DictionaryEntryView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let entryID: String?

    @State private var meaningText = ""
    @State private var outputText = ""
    @State private var isSaving = false
    @State private var showDeleteAlert = false
    @State private var hasLoadedEntry = false

    private var isEditing: Bool {
        entryID != nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                fieldTitle("MEANING")
                TextField("Optional source phrase or meaning", text: $meaningText)
                    .font(AppTypography.ui(size: 13.5))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .appGlassSurface(radius: AppTheme.Radius.medium, stroke: AppColors.inputStroke)

                fieldTitle("OUTPUT TEXT")
                TextField("Paste or type the translated text...", text: $outputText, axis: .vertical)
                    .lineLimit(6 ... 16)
                    .font(AppTypography.ui(size: 13.5))
                    .padding(10)
                    .appGlassSurface(radius: AppTheme.Radius.medium, stroke: AppColors.inputStroke)

                if isEditing {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Text("Delete Entry")
                            .font(AppTypography.ui(size: 13, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppColors.destructive.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.bubble, style: .continuous))
                    }
                    .padding(.top, 8)
                }
            }
            .padding(16)
        }
        .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(isEditing ? "Save" : "Add") {
                    save()
                }
                .disabled(isSaving)
            }
        }
        .alert("Delete Entry", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
        } message: {
            Text("Are you sure you want to delete this entry?")
        }
        .onAppear {
            loadEntryIfNeeded()
        }
    }

    private func fieldTitle(_ text: String) -> some View {
        Text(text)
            .font(AppTypography.ui(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
    }

    private func loadEntryIfNeeded() {
        guard !hasLoadedEntry else {
            return
        }
        hasLoadedEntry = true

        guard let entryID else {
            return
        }

        guard let entry = store.dictionaryEntry(id: entryID) else {
            store.showToast(style: .error, title: "Entry not found")
            dismiss()
            return
        }

        meaningText = entry.meaning
        outputText = entry.outputText
    }

    private func save() {
        let trimmedOutputText = outputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedOutputText.isEmpty else {
            store.showToast(style: .error, title: "Output text is required")
            return
        }

        guard !isSaving else {
            return
        }

        isSaving = true

        Task {
            if let entryID {
                await store.updateDictionaryEntry(id: entryID, meaning: meaningText, outputText: trimmedOutputText)
                dismiss()
                isSaving = false
                return
            }

            guard let result = await store.addManualDictionaryEntry(meaning: meaningText, outputText: trimmedOutputText) else {
                isSaving = false
                return
            }

            if result.status == .added {
                dismiss()
            }

            isSaving = false
        }
    }

    private func deleteEntry() {
        guard let entryID else {
            return
        }

        Task {
            await store.deleteDictionaryEntry(id: entryID)
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        DictionaryEntryView(entryID: nil)
            .environment(AppStore())
    }
}
