//
//  GuitarExtensions.swift
//  Guitars
//

import Foundation

nonisolated extension Acoustic {
    static let standard = Acoustic(topWood: .mahogany, backAndSidesWood: .rosewood)
}

nonisolated extension Electric {
    static let standard = Electric(
        topWood: nil,
        body: .mahogany,
        neckPickup: .humbucker,
        bridgePickup: .humbucker,
        middlePickup: nil,
        bridge: .abr1,
        tailpiece: .stopBar
    )
}

extension Guitar {
    /// "Gibson SG Standard", or just the brand when the model name is empty.
    var displayName: String {
        modelName.isEmpty ? brand.rawValue : "\(brand.rawValue) \(modelName)"
    }

    var sortedImages: [GuitarImage] {
        images.sorted { $0.sortOrder < $1.sortOrder }
    }

    /// The chosen key image, falling back to the first photo.
    var keyImage: GuitarImage? {
        images.first { $0.id == keyImageID } ?? sortedImages.first
    }
}
