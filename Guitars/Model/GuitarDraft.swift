//
//  GuitarDraft.swift
//  Guitars
//

import Foundation

/// An editable copy of a guitar. The editor works on a draft so Cancel
/// leaves the stored guitar untouched; Save copies the draft back.
struct GuitarDraft {
    var guitarType: GuitarType
    var modelName: String
    var modelYear: Int
    var serialNumber: String
    var brand: Brand
    var finish: String
    var neckWood: Wood
    var fretboardWood: Wood
    var acoustic: Acoustic?
    var electric: Electric?
    var hardware: Hardware
    var images: [GuitarImage]
    var keyImageID: UUID?

    init(guitar: Guitar? = nil) {
        let source = guitar ?? Guitar()
        guitarType = source.guitarType
        modelName = source.modelName
        modelYear = source.modelYear
        serialNumber = source.serialNumber
        brand = source.brand
        finish = source.finish
        neckWood = source.neckWood
        fretboardWood = source.fretboardWood
        acoustic = source.acoustic
        electric = source.electric
        hardware = source.hardware
        images = source.images
        keyImageID = source.keyImageID
    }

    func apply(to guitar: Guitar) {
        guitar.guitarType = guitarType
        guitar.modelName = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
        guitar.modelYear = modelYear
        guitar.serialNumber = serialNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guitar.brand = brand
        guitar.finish = finish.trimmingCharacters(in: .whitespacesAndNewlines)
        guitar.neckWood = neckWood
        guitar.fretboardWood = fretboardWood
        guitar.acoustic = acoustic
        guitar.electric = electric
        guitar.hardware = hardware
        guitar.images = images
        guitar.keyImageID = keyImageID
        guitar.modifiedAt = .now
    }

    var sortedImages: [GuitarImage] {
        images.sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Adds Photos-library references after the existing ones, skipping duplicates.
    mutating func appendImages(localIdentifiers: [String]) {
        var next = (images.map(\.sortOrder).max() ?? -1) + 1
        for localID in localIdentifiers where !images.contains(where: { $0.localIdentifier == localID }) {
            images.append(GuitarImage(id: UUID(), cloudIdentifier: nil, localIdentifier: localID, sortOrder: next))
            next += 1
        }
        if keyImageID == nil { keyImageID = sortedImages.first?.id }
    }

    mutating func removeImage(_ image: GuitarImage) {
        images.removeAll { $0.id == image.id }
        if keyImageID == image.id { keyImageID = sortedImages.first?.id }
    }
}
