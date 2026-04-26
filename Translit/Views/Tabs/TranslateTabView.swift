import SwiftUI

private enum TranslateAlertRoute: Identifiable {
    case newConversation
    case modelRequired

    var id: String {
        switch self {
        case .newConversation:
            return "new-conversation"
        case .modelRequired:
            return "model-required"
        }
    }
}

struct TranslateTabView: View {
    @Environment(AppStore.self) private var store

    @State private var draft = ""
    @State private var activeAlert: TranslateAlertRoute?
    @State private var keyboardScrollTask: Task<Void, Never>?
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appGroupedBackground
                    .ignoresSafeArea()

                ScrollViewReader { proxy in
                    Group {
                        if store.currentConversation.isEmpty {
                            EmptyStateView(
                                systemImage: "ellipsis.message",
                                title: "Start a conversation",
                                subtitle: "Type a message below to transliterate or translate your text"
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isInputFocused = false
                            }
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(store.currentConversation) { message in
                                        MessageBubbleView(message: message) { text in
                                            store.copyToClipboard(text)
                                        }
                                        .id(message.id)
                                    }

                                    if store.isSendingMessage {
                                        HStack(spacing: 8) {
                                            ProgressView()
                                                .controlSize(.small)
                                            Text("Translating...")
                                                .font(AppTypography.ui(size: 12))
                                                .foregroundStyle(.secondary)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 4)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 14)
                            }
                            .onChange(of: store.currentConversation.count) { _, _ in
                                scrollToBottom(with: proxy)
                            }
                            .scrollDismissesKeyboard(.interactively)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isInputFocused = false
                            }
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        inputBar
                    }
                    .onChange(of: isInputFocused) { _, _ in
                        scheduleKeyboardAnchorScroll(with: proxy)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isInputFocused = false
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !store.currentConversation.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            activeAlert = .newConversation
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
            }
            .alert(item: $activeAlert) { route in
                switch route {
                case .newConversation:
                    return Alert(
                        title: Text("New Conversation"),
                        message: Text("Are you sure you want to start a new conversation? This will clear all messages."),
                        primaryButton: .destructive(Text("Clear")) {
                            Task {
                                await store.startNewConversation()
                            }
                        },
                        secondaryButton: .cancel()
                    )
                case .modelRequired:
                    return Alert(
                        title: Text("No Model Downloaded"),
                        message: Text("Download an on-device model before sending your first translation."),
                        primaryButton: .default(Text("Download Model")) {
                            store.presentModelManagement()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .onDisappear {
                keyboardScrollTask?.cancel()
            }
        }
    }

    private var inputBar: some View {
        VStack(spacing: 10) {
            messageComposer
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 16)
    }

    private var messageComposer: some View {
        GlassEffectContainer(spacing: 10) {
            HStack(alignment: .bottom, spacing: 10) {
                TextField(inputPlaceholder, text: $draft, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1 ... 5)
                    .font(AppTypography.heading(size: 16, weight: .regular))
                    .autocorrectionDisabled()
                    .disabled(store.selectedLanguage == nil || store.isSendingMessage)
                    .focused($isInputFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .glassEffect(in: .rect(cornerRadius: AppTheme.Radius.bubble))

                Button {
                    sendDraft()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(AppTypography.ui(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.tint(AppColors.tint).interactive(), in: .circle)
                .opacity(canSend ? 1 : 0.55)
                .disabled(!canSend)
            }
        }
    }

    private var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !store.isSendingMessage
            && store.selectedLanguage != nil
    }

    private var inputPlaceholder: String {
        if store.selectedLanguage == nil {
            return "Select a language to continue"
        }

        return "Type a message..."
    }

    private func sendDraft() {
        guard store.hasAnyDownloadedModels else {
            activeAlert = .modelRequired
            return
        }

        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            return
        }

        draft = ""

        Task {
            await store.sendMessage(text)
        }
    }

    private func scrollToBottom(with proxy: ScrollViewProxy) {
        guard let lastID = store.currentConversation.last?.id else {
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(lastID, anchor: .bottom)
        }
    }

    private func scheduleKeyboardAnchorScroll(with proxy: ScrollViewProxy) {
        keyboardScrollTask?.cancel()
        keyboardScrollTask = Task { @MainActor in
            scrollToBottom(with: proxy)

            try? await Task.sleep(for: .milliseconds(180))
            guard !Task.isCancelled else {
                return
            }

            scrollToBottom(with: proxy)
        }
    }
}

#Preview {
    TranslateTabView()
        .environment(AppStore())
}
