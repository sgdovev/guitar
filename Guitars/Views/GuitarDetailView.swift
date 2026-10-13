//
//  GuitarDetailView.swift
//  Guitars
//

import Foundation
import SwiftData
import SwiftUI

struct GuitarDetailView: View {
    let guitar: Guitar

    @Environment(\.layoutMode) private var layoutMode
    @State private var isEditing = false

    var body: some View {
        content
            .navigationTitle(guitar.displayName)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") { isEditing = true }
                }
            }
            .sheet(isPresented: $isEditing) {
                GuitarEditorView(guitar: guitar)
            }
    }

    @ViewBuilder
    private var content: some View {
        if layoutMode.showsWideDetail {
            // Landscape iPad, unfolded phone held wide, Mac: photos beside the specs.
            HStack(spacing: 0) {
                PhotoGallery(images: guitar.sortedImages, startAt: guitar.keyImageID)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Divider()
                List {
                    GuitarSpecs(guitar: guitar)
                }
                .frame(width: 340)
            }
        } else {
            // Portrait and phones: photos on top, specs below.
            List {
                Section {
                    PhotoGallery(images: guitar.sortedImages, startAt: guitar.keyImageID)
                        .frame(height: layoutMode == .regularPortrait ? 440 : 280)
                        .listRowInsets(EdgeInsets())
                }
                GuitarSpecs(guitar: guitar)
            }
        }
    }
}

/// Swipe (or scroll on the Mac) through a guitar's photos.
struct PhotoGallery: View {
    let images: [GuitarImage]
    let startAt: UUID?

    @State private var currentID: UUID?

    var body: some View {
        if images.isEmpty {
            ContentUnavailableView("No Photos", systemImage: "photo.on.rectangle")
        } else {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(images) { image in
                        PhotoAssetView(image: image, contentMode: .fit, targetSize: CGSize(width: 1200, height: 1200))
                            .containerRelativeFrame([.horizontal, .vertical])
                            .id(image.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollPosition(id: $currentID)
            .onAppear { currentID = startAt ?? images.first?.id }
        }
    }
}

struct GuitarSpecs: View {
    let guitar: Guitar

    var body: some View {
        Section("Guitar") {
            LabeledContent("Brand", value: guitar.brand.rawValue)
            LabeledContent("Model", value: guitar.modelName)
            LabeledContent("Year", value: String(guitar.modelYear))
            LabeledContent("Type", value: guitar.guitarType.rawValue)
            LabeledContent("Serial Number", value: guitar.serialNumber)
            LabeledContent("Finish", value: guitar.finish)
        }
        Section("Construction") {
            LabeledContent("Neck", value: guitar.neckWood.rawValue)
            LabeledContent("Fretboard", value: guitar.fretboardWood.rawValue)
            LabeledContent("Hardware", value: guitar.hardware.rawValue)
        }
        if let acoustic = guitar.acoustic {
            Section("Acoustic") {
                LabeledContent("Top", value: acoustic.topWood.rawValue)
                LabeledContent("Back & Sides", value: acoustic.backAndSidesWood.rawValue)
            }
        }
        if let electric = guitar.electric {
            Section("Electric") {
                LabeledContent("Body", value: electric.body.rawValue)
                LabeledContent("Top", value: electric.topWood?.rawValue ?? "None")
                LabeledContent("Neck Pickup", value: electric.neckPickup?.rawValue ?? "None")
                LabeledContent("Middle Pickup", value: electric.middlePickup?.rawValue ?? "None")
                LabeledContent("Bridge Pickup", value: electric.bridgePickup?.rawValue ?? "None")
                LabeledContent("Bridge", value: electric.bridge.rawValue)
                LabeledContent("Tailpiece", value: electric.tailpiece.rawValue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        GuitarDetailView(guitar: Guitar.samples[0])
    }
    .modelContainer(.preview)
}
