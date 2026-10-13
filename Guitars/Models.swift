//
//  Models.swift
//  Guitars
//
//  Created by Bob Nickolopoulos on 10/13/26.
//

import Foundation

struct Guitar: Identifiable, Codable {
    var id: Int
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
    var keyImage: GuitarImage?
    
}

struct Acoustic: Codable {
    var topWood: Wood
    var backAndSidesWood: Wood
}
struct Electric: Codable {
    var topWood: Wood?
    var body: Wood
    var neckPickup: Pickup?
    var bridgePickup: Pickup?
    var middlePickup: Pickup?
    var bridge: Bridge
    var tailpiece: Tailpiece
}


enum Wood: String, Codable, CaseIterable {
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

enum GuitarType: String, Codable, CaseIterable {
    case acoustic = "Acoustic"
    case electric = "Electric"
    case bass = "Bass"
    case mandolin = "Mandolin"
}

enum Pickup: String, Codable, CaseIterable {
    case single = "Single"
    case humbucker = "Humbucker"
    case p90 = "P90"
    case miniHumbucker = "Mini Humbucker"
    case singleSingleHumbucker = "Single Single Humbucker"
}

enum Brand: String, Codable, CaseIterable {
    case fender = "Fender"
    case gibson = "Gibson"
    case kopp = "Kopp"
    case martin = "Martin"
    case other = "Other"
}

enum Hardware: String, Codable, CaseIterable {
    case nickle = "Nickel"
    case gold = "Gold"
    case chrome = "Chrome"
}

enum Bridge: String, Codable, CaseIterable {
    case abr1 = "ABR-1"
    case nashville = "Nashville"
    case wraparound = "Wraparound"
    case other = "Other"
}


enum Tailpiece: String, Codable, CaseIterable {
    case stopBar = "Stop Bar"
    case maestroVibrola = "Maestro Vibrola"
    case shortMaestroVibrola = "Short Maestro Vibrola"
    case bigsby = "Bigsby"
    case lightningBar = "Lightning Bar"
    case other = "Other"
}

struct GuitarImage: Codable, Identifiable {
    var id: UUID
    var cloudIdentifier: String?
    var localIdentifier: String
    var sortOrder: Int
}
