import Foundation

struct SkylightEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var location: String
    var lastCheckDate: String
    var sealCondition: String
    var notes: String
    var createdAt: Date

    init(id: UUID = UUID(), location: String, lastCheckDate: String, sealCondition: String, notes: String = "", createdAt: Date = Date()) {
        self.id = id
        self.location = location
        self.lastCheckDate = lastCheckDate
        self.sealCondition = sealCondition
        self.notes = notes
        self.createdAt = createdAt
    }
}
