//
//  SyncMerger.swift
//  Guitars
//

import Foundation
import SwiftData

/// Merges a received `.guitarinventory` file into this device's guitars.
/// Guitars match by `id`; the copy with the newer `modifiedAt` wins, and a
/// delete wins over any edit made before it.
@MainActor
enum SyncMerger {
    struct Summary {
        var added = 0
        var updated = 0
        var removed = 0
        var unchanged = 0

        var message: String {
            if added + updated + removed == 0 {
                return "Everything was already up to date."
            }
            return "\(added) added, \(updated) updated, \(removed) removed."
        }
    }

    enum ImportError: LocalizedError {
        case newerFormat

        var errorDescription: String? {
            "This file was made by a newer version of Guitars. Update the app on this device and try again."
        }
    }

    static func importFile(at url: URL, into context: ModelContext) throws -> Summary {
        let isScoped = url.startAccessingSecurityScopedResource()
        defer {
            if isScoped { url.stopAccessingSecurityScopedResource() }
        }
        let package = try InventoryPackage.decode(from: Data(contentsOf: url))
        return try merge(package, into: context)
    }

    static func merge(_ package: InventoryPackage, into context: ModelContext) throws -> Summary {
        guard package.formatVersion <= InventoryPackage.currentFormatVersion else {
            throw ImportError.newerFormat
        }
        var summary = Summary()

        var guitarsByID = Dictionary(
            try context.fetch(FetchDescriptor<Guitar>()).map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        var tombstonesByID = Dictionary(
            try context.fetch(FetchDescriptor<Tombstone>()).map { ($0.guitarID, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        // Deletes first, so an incoming delete removes our copy unless we edited it afterwards.
        for record in package.tombstones {
            if let tombstone = tombstonesByID[record.guitarID] {
                tombstone.deletedAt = max(tombstone.deletedAt, record.deletedAt)
            } else {
                let tombstone = Tombstone(guitarID: record.guitarID, deletedAt: record.deletedAt)
                context.insert(tombstone)
                tombstonesByID[record.guitarID] = tombstone
            }
            if let guitar = guitarsByID[record.guitarID], guitar.modifiedAt <= record.deletedAt {
                context.delete(guitar)
                guitarsByID[record.guitarID] = nil
                summary.removed += 1
            }
        }

        // Re-point incoming photos at this device's Photos library where we can.
        let incomingCloudIDs = package.guitars.flatMap(\.images).compactMap(\.cloudIdentifier)
        let localIDsByCloudID = PhotoLibrary.localIdentifiers(forCloudIdentifiers: incomingCloudIDs)

        for record in package.guitars {
            if let tombstone = tombstonesByID[record.id], tombstone.deletedAt >= record.modifiedAt {
                summary.unchanged += 1
                continue
            }
            let images = record.images.map { image in
                var image = image
                if let cloudID = image.cloudIdentifier, let localID = localIDsByCloudID[cloudID] {
                    image.localIdentifier = localID
                }
                return image
            }
            if let guitar = guitarsByID[record.id] {
                if record.modifiedAt > guitar.modifiedAt {
                    record.apply(to: guitar, images: images)
                    summary.updated += 1
                } else {
                    summary.unchanged += 1
                }
            } else {
                let guitar = Guitar(id: record.id)
                record.apply(to: guitar, images: images)
                context.insert(guitar)
                guitarsByID[record.id] = guitar
                summary.added += 1
            }
        }

        try context.save()
        return summary
    }
}
