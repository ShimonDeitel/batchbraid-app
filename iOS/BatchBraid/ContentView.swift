import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            BraidListView()
                .tabItem { Label("Home", systemImage: "list.bullet.clipboard") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(BBTheme.accent)
    }
}

struct BraidListView: View {
    @EnvironmentObject private var store: BatchBraidStore
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var editingItem: Braid?

    var body: some View {
        NavigationStack {
            ZStack {
                BBTheme.backdrop.ignoresSafeArea()
                if store.braids.isEmpty {
                    ContentUnavailableView("No Braids Yet", systemImage: "square.stack.3d.up", description: Text("Tap + to log your first entry."))
                } else {
                    List {
                        ForEach(store.braids) { item in
                            BraidRow(item: item)
                                .listRowBackground(BBTheme.card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingItem = item
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        store.deleteBraid(item.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Batch Braid")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addBraidButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                BraidFormView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                BraidFormView(mode: .edit(item))
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

struct BraidRow: View {
    let item: Braid

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.projectName)
                .font(BBTheme.headlineFont)
                .foregroundStyle(BBTheme.ink)
            Text(String(describing: item.cordLength))
                .font(.caption)
                .foregroundStyle(BBTheme.inkFaded)
        }
        .padding(.vertical, 4)
    }
}

enum BraidFormMode: Identifiable {
    case add
    case edit(Braid)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct BraidFormView: View {
    @EnvironmentObject private var store: BatchBraidStore
    @EnvironmentObject private var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    let mode: BraidFormMode

    @State private var draftProjectName: String = ""
    @State private var draftCordLength: String = ""
    @State private var draftPattern: String = ""
    @State private var draftFinishedSize: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BBTheme.backdrop.ignoresSafeArea()
                Form {
                    Section {
                TextField("Project", text: $draftProjectName)
                    .accessibilityIdentifier("projectNameField")
                TextField("Cord Length (ft)", text: $draftCordLength)
                    .accessibilityIdentifier("cordLengthField")
                Picker("Knot Pattern", selection: $draftPattern) {
                    ForEach(BBPatternOption.all, id: \.self) { Text($0) }
                }
                TextField("Finished Size (in)", text: $draftFinishedSize)
                    .accessibilityIdentifier("finishedSizeField")
                    }
                    .listRowBackground(BBTheme.card)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("braidSaveButton")
                }
            }
            .onAppear { loadIfEditing() }
            .dismissKeyboardOnTap()
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftProjectName = item.projectName
        draftCordLength = item.cordLength
        draftPattern = item.pattern
        draftFinishedSize = item.finishedSize
        } else {
        draftProjectName = ""
        draftCordLength = ""
        draftPattern = ""
        draftFinishedSize = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.addBraid(draftProjectName, draftCordLength, draftPattern, draftFinishedSize, isPro: purchases.isPro)
        case .edit(let item):
            store.updateBraid(item.id, draftProjectName, draftCordLength, draftPattern, draftFinishedSize)
        }
        BBHaptics.success()
        dismiss()
    }
}
