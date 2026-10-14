//
//  PhotoAssetView.swift
//  Guitars
//

import SwiftUI

/// Shows one guitar photo straight from the Photos library.
struct PhotoAssetView: View {
    let image: GuitarImage
    var contentMode: ContentMode = .fill
    /// Size in points; converted to pixels for the request.
    var targetSize = CGSize(width: 400, height: 400)

    @Environment(\.displayScale) private var displayScale
    @Environment(\.scenePhase) private var scenePhase
    @State private var loaded: PlatformImage?
    @State private var isMissing = false
    /// Bumped to retry, e.g. after the user grants Full Access in Settings.
    @State private var attempt = 0

    var body: some View {
        ZStack {
            if let loaded {
                Image(platformImage: loaded)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isMissing && targetSize.width < 150 {
                Image(systemName: "photo.badge.exclamationmark")
                    .foregroundStyle(.secondary)
            } else if isMissing {
                ContentUnavailableView {
                    Label("Photo Unavailable", systemImage: "photo.badge.exclamationmark")
                } description: {
                    Text(PhotoLibrary.access == .full
                         ? "This photo isn't in this device's Photos library."
                         : "Guitars needs Full Access to your Photos library to show this photo.")
                }
                .font(.caption)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.quaternary)
        .task(id: LoadKey(image: image, attempt: attempt)) {
            loaded = nil
            isMissing = false
            await PhotoLibrary.requestAccess()
            let pixels = CGSize(width: targetSize.width * displayScale, height: targetSize.height * displayScale)
            loaded = await PhotoLibrary.image(for: image, targetSize: pixels)
            isMissing = loaded == nil
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active && isMissing { attempt += 1 }
        }
    }
}

private struct LoadKey: Equatable {
    let image: GuitarImage
    let attempt: Int
}
