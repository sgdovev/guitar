//
//  SampleData.swift
//  Guitars
//

import Foundation
import SwiftData

extension Guitar {
    static var samples: [Guitar] {
        [
            Guitar(guitarType: .electric, modelName: "SG Standard", modelYear: 2005,
                   serialNumber: "A10005", brand: .gibson, hardware: .nickle),
            Guitar(guitarType: .electric, modelName: "Stratocaster", modelYear: 1998,
                   serialNumber: "N8123456", brand: .fender, neckWood: .maplePlain,
                   fretboardWood: .maplePlain,
                   electric: Electric(topWood: nil, body: .alder, neckPickup: .single,
                                      bridgePickup: .single, middlePickup: .single,
                                      bridge: .other, tailpiece: .other),
                   hardware: .chrome),
            Guitar(guitarType: .acoustic, modelName: "D-28", modelYear: 2019,
                   serialNumber: "2234567", brand: .martin, neckWood: .mahogany,
                   fretboardWood: .ebony, acoustic: .standard, electric: nil),
        ]
    }
}

extension ModelContainer {
    /// In-memory container with sample guitars, for previews.
    @MainActor
    static let preview: ModelContainer = {
        do {
            let container = try ModelContainer(
                for: Guitar.self, Tombstone.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            for guitar in Guitar.samples {
                container.mainContext.insert(guitar)
            }
            return container
        } catch {
            fatalError("Couldn't create the preview container: \(error)")
        }
    }()
}
