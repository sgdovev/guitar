//
//  Models.swift
//  Guitars
//
//  Created by Bob Nickolopoulos on 10/13/26.
//

import Foundation
import SwiftData

// Stored with SwiftData. `id` is a UUID (not an Int) so guitars created on
// different devices never collide when they're merged over AirDrop.
@Model
final class Guitar {
    @Attribute(.unique) var id: UUID
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
    /// Points at one of `images`, so the key image is never a second copy.
    var keyImageID: UUID?
    /// Bumped on every edit; the newer copy wins when merging an AirDrop import.
    var modifiedAt: Date

    init(
        id: UUID = UUID(),
        guitarType: GuitarType = .electric,
        modelName: String = "",
        modelYear: Int = Calendar.current.component(.year, from: .now),
        serialNumber: String = "",
        brand: Brand = .gibson,
        neckWood: Wood = .mahogany,
        fretboardWood: Wood = .rosewood,
        acoustic: Acoustic? = nil,
        electric: Electric? = .standard,
        hardware: Hardware = .nickle,
        images: [GuitarImage] = [],
        keyImageID: UUID? = nil,
        modifiedAt: Date = .now
    ) {
        self.id = id
        self.guitarType = guitarType
        self.modelName = modelName
        self.modelYear = modelYear
        self.serialNumber = serialNumber
        self.brand = brand
        self.neckWood = neckWood
        self.fretboardWood = fretboardWood
        self.acoustic = acoustic
        self.electric = electric
        self.hardware = hardware
        self.images = images
        self.keyImageID = keyImageID
        self.modifiedAt = modifiedAt
    }
}

nonisolated struct Acoustic: Codable, Hashable {
    var topWood: Wood
    var backAndSidesWood: Wood
}
nonisolated struct Electric: Codable, Hashable {
    var topWood: Wood?
    var body: Wood
    var neckPickup: Pickup?
    var bridgePickup: Pickup?
    var middlePickup: Pickup?
    var bridge: Bridge
    var tailpiece: Tailpiece
}


nonisolated enum Wood: String, Codable, CaseIterable {
    case alder = "Alder"
    case ash = "Ash"
    case ebony = "Ebony"
    case mahogany = "Mahogany"
    case maplePlain = "Maple Plain"
    case mapleQulted = "Maple Quilted"
    case mapleFlamed = "Maple Flamed"
    case poplar = "Poplar"
    case rosewood = "Rosewood"
    case richlite = "Richlite"
}

nonisolated enum GuitarType: String, Codable, CaseIterable {
    case acoustic = "Acoustic"
    case electric = "Electric"
    case bass = "Bass"
    case mandolin = "Mandolin"
}

nonisolated enum Pickup: String, Codable, CaseIterable {
    case single = "Single"
    case humbucker = "Humbucker"
    case p90 = "P90"
    case miniHumbucker = "Mini Humbucker"
    case singleSingleHumbucker = "Single Single Humbucker"
}

nonisolated enum Brand: String, Codable, CaseIterable {
    case fender = "Fender"
    case gibson = "Gibson"
    case kopp = "Kopp"
    case martin = "Martin"
    case other = "Other"
}

nonisolated enum Hardware: String, Codable, CaseIterable {
    case nickle = "Nickel"
    case gold = "Gold"
    case chrome = "Chrome"
}

nonisolated enum Bridge: String, Codable, CaseIterable {
    case abr1 = "ABR-1"
    case nashville = "Nashville"
    case wraparound = "Wraparound"
    case other = "Other"
}


nonisolated enum Tailpiece: String, Codable, CaseIterable {
    case stopBar = "Stop Bar"
    case maestroVibrola = "Maestro Vibrola"
    case shortMaestroVibrola = "Short Maestro Vibrola"
    case bigsby = "Bigsby"
    case lightningBar = "Lightning Bar"
    case other = "Other"
}

nonisolated struct GuitarImage: Codable, Hashable, Identifiable {
    var id: UUID
    var cloudIdentifier: String?
    var localIdentifier: String
    var sortOrder: Int
}
