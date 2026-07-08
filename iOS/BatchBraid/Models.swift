import Foundation

struct Braid: Identifiable, Codable, Equatable {
    let id: UUID
    var projectName: String
    var cordLength: String
    var pattern: String
    var finishedSize: String
    var createdDate: Date

    init(id: UUID = UUID(), projectName: String = "Keychain Fob", cordLength: String = "6", pattern: String = "Cobra", finishedSize: String = "4", createdDate: Date = Date()) {
        self.id = id
        self.projectName = projectName
        self.cordLength = cordLength
        self.pattern = pattern
        self.finishedSize = finishedSize
        self.createdDate = createdDate
    }
}

/// Pro bonus feature entry: Cord-Length Calculator.
struct BBProEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var pattern: String
    var targetLength: String
    var strands: String
    var resultLength: String
    var createdDate: Date

    init(id: UUID = UUID(), pattern: String = "Cobra", targetLength: String = "8", strands: String = "2", resultLength: String = "7.5", createdDate: Date = Date()) {
        self.id = id
        self.pattern = pattern
        self.targetLength = targetLength
        self.strands = strands
        self.resultLength = resultLength
        self.createdDate = createdDate
    }
}

enum BBPatternOption {
    static let all = ["Cobra", "Fishtail", "King Cobra", "Solomon", "Trilobite"]
}
