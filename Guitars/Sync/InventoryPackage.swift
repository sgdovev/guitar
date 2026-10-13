//
//  InventoryPackage.swift
//  Guitars
//
//  The file that travels over AirDrop: every guitar plus the deletes, as JSON
//  with a `.guitarinventory` extension. No cloud service is involved.
//

import Foundation
import UniformTypeIdentifiers

nonisolated extension UTType {
    /// Declared in Config/Info.plist (UTExportedTypeDeclarations).
    static let guitarInventory = UTType(exportedAs: "com.bnick.Guitars.inventory")
}

nonisolated struct InventoryPackage: Codable {
    static let currentFormatVersion = 1

    var formatVersion = InventoryPackage.currentFormatVersion
    var exportedAt: Date
    var guitars: [GuitarRecord]
    var tombstones: [TombstoneRecord]

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    static func decode(from data: Data) throws -> InventoryPackage {
        try JSONDecoder().decode(InventoryPackage.self, from: data)
    }
}

/// A plain copy of a `Guitar` for the file.
nonisolated struct GuitarRecord: Codable {
    var id: UUID
    var guitarType: GuitarType
    var modelName: String
    var modelYear: Int
    var serialNumber: String
    var brand: Brand
    var neckWood: Wood
    var fretboardWood: Wood
    var acoustic: Acoustic?
    var electric: Electric?
    var hardware: Hardware
    var images: [GuitarImage]
    var keyImageID: UUID?
    var modifiedAt: Date

    @MainActor
    init(_ guitar: Guitar) {
        id = guitar.id
        guitarType = guitar.guitarType
        modelName = guitar.modelName
        modelYear = guitar.modelYear
        serialNumber = guitar.serialNumber
        brand = guitar.brand
        neckWood = guitar.neckWood
        fretboardWood = guitar.fretboardWood
        acoustic = guitar.acoustic
        electric = guitar.electric
        hardware = guitar.hardware
        images = guitar.images
        keyImageID = guitar.keyImageID
        modifiedAt = guitar.modifiedAt
    }

    /// Copies this record onto a stored guitar, using `images` already
    /// re-pointed at this device's Photos library.
    @MainActor
    func apply(to guitar: Guitar, images: [GuitarImage]) {
        guitar.guitarType = guitarType
        guitar.modelName = modelName
        guitar.modelYear = modelYear
        guitar.serialNumber = serialNumber
        guitar.brand = brand
        guitar.neckWood = neckWood
        guitar.fretboardWood = fretboardWood
        guitar.acoustic = acoustic
        guitar.electric = electric
        guitar.hardware = hardware
        guitar.images = images
        guitar.keyImageID = keyImageID
        guitar.modifiedAt = modifiedAt
    }
}

nonisolated struct TombstoneRecord: Codable {
    var guitarID: UUID
    var deletedAt: Date
}
