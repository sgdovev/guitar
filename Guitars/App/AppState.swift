//
//  AppState.swift
//  Guitars
//

import Observation
import SwiftUI

/// Navigation state shared by every layout, so rotating or unfolding the
/// device keeps the selected guitar.
@Observable
final class AppState {
    var selection: Guitar?
    var filter: SidebarFilter = .all
    var isAddingGuitar = false
    var isImporting = false
}

nonisolated enum SidebarFilter: Hashable {
    case all
    case brand(Brand)
    case type(GuitarType)

    var title: String {
        switch self {
        case .all: "All Guitars"
        case .brand(let brand): brand.rawValue
        case .type(let type): type.rawValue
        }
    }

    @MainActor
    func matches(_ guitar: Guitar) -> Bool {
        switch self {
        case .all: true
        case .brand(let brand): guitar.brand == brand
        case .type(let type): guitar.guitarType == type
        }
    }
}
