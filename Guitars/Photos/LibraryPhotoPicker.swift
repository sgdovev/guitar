//
//  LibraryPhotoPicker.swift
//  Guitars
//

import Photos
import PhotosUI
import SwiftUI

/// Picks any number of photos and hands back their Photos-library identifiers.
/// Using the shared library is what makes `itemIdentifier` available; no image
/// data is loaded.
struct LibraryPhotoPicker: View {
    let onPick: ([String]) -> Void

    @State private var items: [PhotosPickerItem] = []

    var body: some View {
        PhotosPicker(
            selection: $items,
            maxSelectionCount: nil,
            selectionBehavior: .ordered,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Label("Add from Photos", systemImage: "photo.on.rectangle.angled")
        }
        .onChange(of: items) { _, newItems in
            guard !newItems.isEmpty else { return }
            onPick(newItems.compactMap(\.itemIdentifier))
            items = []
        }
        .task {
            await PhotoLibrary.requestAccess()
        }
    }
}
