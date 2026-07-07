import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: BatchBraidStore
    @EnvironmentObject private var purchases: PurchaseManager
    @AppStorage("batchbraid_haptics_enabled") private var hapticsEnabled: Bool = true
    @AppStorage("batchbraid_show_notes") private var showNotes: Bool = true

    @State private var showingDeleteConfirm = false
    @State private var showingPaywall = false
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                BBTheme.backdrop.ignoresSafeArea()

                Form {
                    Section {
                        if purchases.isPro {
                            HStack {
                                Image(systemName: "checkmark.seal.fill").foregroundStyle(BBTheme.accent)
                                Text("Batch Braid Pro active")
                                    .foregroundStyle(BBTheme.ink)
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                HStack {
                                    Image(systemName: "star.fill").foregroundStyle(BBTheme.accent2)
                                    Text("Unlock Pro")
                                        .foregroundStyle(BBTheme.ink)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(BBTheme.inkFaded)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("settingsUnlockProButton")
                        }
                    }
                    .listRowBackground(BBTheme.card)

                    if purchases.isPro {
                        Section("Cord-Length Calculator") {
                            Text("Calculate cord length needed by braid pattern and target length.")
                                .font(.caption)
                                .foregroundStyle(BBTheme.inkFaded)
                            ForEach(store.proEntries) { p in
                                HStack {
                                    Text(p.pattern)
                                        .foregroundStyle(BBTheme.ink)
                                    Spacer()
                                    Text(p.targetLength)
                                        .font(.caption)
                                        .foregroundStyle(BBTheme.accent)
                                }
                            }
                            .onDelete { offsets in
                                for idx in offsets { store.deleteProEntry(store.proEntries[idx].id) }
                            }
                        }
                        .listRowBackground(BBTheme.card)
                    }

                    Section("Preferences") {
                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                            .onChange(of: hapticsEnabled) { _, newValue in
                                BBHaptics.enabled = newValue
                            }
                        Toggle("Show Notes", isOn: $showNotes)
                    }
                    .listRowBackground(BBTheme.card)

                    Section {
                        Button {
                            if store.canAdd(isPro: purchases.isPro) {
                                showingAdd = true
                            } else {
                                showingPaywall = true
                            }
                        } label: {
                            Label("Add Entry", systemImage: "plus")
                        }
                        .accessibilityIdentifier("settingsAddBraidButton")
                    }
                    .listRowBackground(BBTheme.card)

                    Section {
                        Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/batchbraid-app/privacy.html")!)
                        Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/batchbraid-app/terms.html")!)
                        Button("Restore Purchases") {
                            Task { await purchases.restore() }
                        }
                    }
                    .listRowBackground(BBTheme.card)

                    Section {
                        Button("Delete All Data", role: .destructive) {
                            showingDeleteConfirm = true
                        }
                    }
                    .listRowBackground(BBTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all data? This cannot be undone.", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete Everything", role: .destructive) {
                    store.deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingAdd) {
                BraidFormView(mode: .add)
            }
        }
    }
}
