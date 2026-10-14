//
//  InventoryExport.swift
//  Guitars
//

import CoreTransferable
import Foundation
import SwiftData
import UniformTypeIdentifiers

/// What the Share button hands to the share sheet (AirDrop included). The file
/// is built only when the user actually shares, not on every redraw.
nonisolated struct InventoryExport: Transferable {
    let container: ModelContainer

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .guitarInventory) { export in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("Guitar Inventory")
                .appendingPathExtension(for: .guitarInventory)
            try await export.data().write(to: url, options: .atomic)
            return SentTransferredFile(url)
        }
    }

    func data() async throws -> Data {
        try await MainActor.run {
            try InventoryExport.makePackage(context: container.mainContext).encoded()
        }
    }

    @MainActor
    static func makePackage(context: ModelContext) throws -> InventoryPackage {
        let guitars = try context.fetch(FetchDescriptor<Guitar>())
        fillInCloudIdentifiers(for: guitars)
        let tombstones = try context.fetch(FetchDescriptor<Tombstone>())
        return InventoryPackage(
            exportedAt: .now,
            guitars: guitars.map { GuitarRecord($0) },
            tombstones: tombstones.map { TombstoneRecord(guitarID: $0.guitarID, deletedAt: $0.deletedAt) }
        )
    }

    /// Local photo identifiers mean nothing on another device, so make sure each
    /// photo also carries its cloud identifier before it leaves this one.
    @MainActor
    private static func fillInCloudIdentifiers(for guitars: [Guitar]) {
        let missing = guitars.flatMap(\.images).filter { $0.cloudIdentifier == nil }.map(\.localIdentifier)
        let cloudIDs = PhotoLibrary.cloudIdentifiers(for: missing)
        guard !cloudIDs.isEmpty else { return }
        for guitar in guitars where guitar.images.contains(where: { $0.cloudIdentifier == nil && cloudIDs[$0.localIdentifier] != nil }) {
            guitar.images = guitar.images.map { image in
                var image = image
                if image.cloudIdentifier == nil {
                    image.cloudIdentifier = cloudIDs[image.localIdentifier]
                }
                return image
            }
        }
    }
}
