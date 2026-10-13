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
    @State private var loaded: PlatformImage?
    @State private var isMissing = false

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
                    Text("This photo isn't in this device's Photos library.")
                }
                .font(.caption)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.quaternary)
        .task(id: image) {
            loaded = nil
            isMissing = false
            await PhotoLibrary.requestAccess()
            let pixels = CGSize(width: targetSize.width * displayScale, height: targetSize.height * displayScale)
            loaded = await PhotoLibrary.image(for: image, targetSize: pixels)
            isMissing = loaded == nil
        }
    }
}
