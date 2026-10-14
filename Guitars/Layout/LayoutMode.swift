//
//  LayoutMode.swift
//  Guitars
//
//  One place decides which layout to use, from the window's size class and
//  shape rather than the device model. That covers iPhone portrait and
//  landscape, iPad portrait and landscape (including Split View), the Mac, and
//  a folding iPhone: folded it reports a compact width, unfolded a regular one,
//  and SwiftUI re-renders when it changes.
//

import SwiftUI

nonisolated enum LayoutMode: Hashable {
    /// iPhone upright, a folded phone, or a narrow iPad window: one column, push navigation.
    case compact
    /// iPhone on its side: list and detail side by side.
    case compactLandscape
    /// iPad upright or an unfolded phone held tall: list and a large detail.
    case regularPortrait
    /// iPad on its side or an unfolded phone held wide: sidebar, list and detail.
    case regularLandscape
    /// The Mac.
    case desktop

    /// Photos and specs side by side in the detail view.
    var showsWideDetail: Bool {
        self == .regularLandscape || self == .desktop
    }

    #if os(iOS)
    static func resolve(
        size: CGSize,
        horizontalSizeClass: UserInterfaceSizeClass?,
        verticalSizeClass: UserInterfaceSizeClass?
    ) -> LayoutMode {
        if verticalSizeClass == .compact {
            return .compactLandscape
        }
        if horizontalSizeClass == .compact {
            return .compact
        }
        return size.width > size.height ? .regularLandscape : .regularPortrait
    }
    #endif
}

extension EnvironmentValues {
    @Entry var layoutMode: LayoutMode = .compact
}
