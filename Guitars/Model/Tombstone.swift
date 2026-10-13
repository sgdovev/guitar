//
//  Tombstone.swift
//  Guitars
//

import Foundation
import SwiftData

/// Remembers that a guitar was deleted, so the delete travels with the next
/// AirDrop export instead of the guitar coming back from another device.
@Model
final class Tombstone {
    @Attribute(.unique) var guitarID: UUID
    var deletedAt: Date

    init(guitarID: UUID, deletedAt: Date = .now) {
        self.guitarID = guitarID
        self.deletedAt = deletedAt
    }
}

extension ModelContext {
    /// Deletes a guitar and leaves a tombstone behind for sync.
    func deleteGuitar(_ guitar: Guitar) {
        let id = guitar.id
        delete(guitar)
        let existing = try? fetch(FetchDescriptor<Tombstone>(predicate: #Predicate { $0.guitarID == id }))
        if let tombstone = existing?.first {
            tombstone.deletedAt = .now
        } else {
            insert(Tombstone(guitarID: id))
        }
    }
}
