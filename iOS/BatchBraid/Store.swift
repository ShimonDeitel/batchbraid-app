import Foundation

@MainActor
final class BatchBraidStore: ObservableObject {
    @Published private(set) var braids: [Braid] = []
    @Published private(set) var proEntries: [BBProEntry] = []

    static let freeLimit = 30

    private let fileURL: URL
    private let proFileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("batchbraid_braids.json")
        self.proFileURL = dir.appendingPathComponent("batchbraid_pro.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: proFileURL)
        }
        load()
        if braids.isEmpty {
            seedDefaults()
        }
        if proEntries.isEmpty {
            seedProDefaults()
        }
    }

    private func seedDefaults() {
        braids = [
            Braid(projectName: "Keychain Fob", cordLength: "6", pattern: "Cobra", finishedSize: "4"),
            Braid(projectName: "Dog Leash", cordLength: "30", pattern: "Fishtail", finishedSize: "48"),
            Braid(projectName: "Survival Bracelet", cordLength: "10", pattern: "King Cobra", finishedSize: "8")
        ]
        save()
    }

    private func seedProDefaults() {
        proEntries = [
            BBProEntry(pattern: "Cobra", targetLength: "8", strands: "2", resultLength: "7.5"),
            BBProEntry(pattern: "Fishtail", targetLength: "48", strands: "2", resultLength: "30")
        ]
        saveProEntries()
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || braids.count < Self.freeLimit
    }

    @discardableResult
    func addBraid(projectName: String, cordLength: String, pattern: String, finishedSize: String, isPro: Bool) -> Bool {
        let trimmed = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAdd(isPro: isPro) else { return false }
        let item = Braid(projectName: projectName, cordLength: cordLength, pattern: pattern, finishedSize: finishedSize)
        braids.append(item)
        save()
        return true
    }

    func updateBraid(_ id: UUID, projectName: String, cordLength: String, pattern: String, finishedSize: String) {
        guard let idx = braids.firstIndex(where: { $0.id == id }) else { return }
        braids[idx].projectName = projectName
        braids[idx].cordLength = cordLength
        braids[idx].pattern = pattern
        braids[idx].finishedSize = finishedSize
        save()
    }

    func deleteBraid(_ id: UUID) {
        braids.removeAll { $0.id == id }
        save()
    }

    func deleteAllData() {
        braids = []
        proEntries = []
        seedDefaults()
        seedProDefaults()
    }

    // MARK: - Pro entries

    @discardableResult
    func addProEntry(pattern: String, targetLength: String, strands: String, resultLength: String) -> Bool {
        let entry = BBProEntry(pattern: pattern, targetLength: targetLength, strands: strands, resultLength: resultLength)
        proEntries.append(entry)
        saveProEntries()
        return true
    }

    func deleteProEntry(_ id: UUID) {
        proEntries.removeAll { $0.id == id }
        saveProEntries()
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var items: [Braid]
    }
    private struct ProSnapshot: Codable {
        var items: [BBProEntry]
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            braids = decoded.items
        }
        if let data = try? Data(contentsOf: proFileURL), let decoded = try? JSONDecoder().decode(ProSnapshot.self, from: data) {
            proEntries = decoded.items
        }
    }

    private func save() {
        let snapshot = Snapshot(items: braids)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func saveProEntries() {
        let snapshot = ProSnapshot(items: proEntries)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: proFileURL, options: .atomic)
    }
}
