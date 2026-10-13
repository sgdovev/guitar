//
//  GuitarEditorView.swift
//  Guitars
//

import Foundation
import SwiftData
import SwiftUI
#if os(iOS)
import UIKit
#endif

/// Adds a new guitar (`guitar == nil`) or edits an existing one.
struct GuitarEditorView: View {
    let guitar: Guitar?

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var draft: GuitarDraft
    @State private var isShowingCamera = false
    @State private var photoError: String?

    init(guitar: Guitar?) {
        self.guitar = guitar
        _draft = State(initialValue: GuitarDraft(guitar: guitar))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Guitar") {
                    EnumPicker(title: "Type", selection: $draft.guitarType)
                    EnumPicker(title: "Brand", selection: $draft.brand)
                    TextField("Model", text: $draft.modelName)
                    TextField("Year", value: $draft.modelYear, format: .number.grouping(.never))
                    TextField("Serial Number", text: $draft.serialNumber)
                }

                Section("Construction") {
                    EnumPicker(title: "Neck", selection: $draft.neckWood)
                    EnumPicker(title: "Fretboard", selection: $draft.fretboardWood)
                    EnumPicker(title: "Hardware", selection: $draft.hardware)
                }

                Section {
                    Toggle("Acoustic Body", isOn: hasAcoustic)
                    if let acoustic = Binding($draft.acoustic) {
                        EnumPicker(title: "Top", selection: acoustic.topWood)
                        EnumPicker(title: "Back & Sides", selection: acoustic.backAndSidesWood)
                    }
                }

                Section {
                    Toggle("Electric", isOn: hasElectric)
                    if let electric = Binding($draft.electric) {
                        EnumPicker(title: "Body", selection: electric.body)
                        OptionalEnumPicker(title: "Top", selection: electric.topWood)
                        OptionalEnumPicker(title: "Neck Pickup", selection: electric.neckPickup)
                        OptionalEnumPicker(title: "Middle Pickup", selection: electric.middlePickup)
                        OptionalEnumPicker(title: "Bridge Pickup", selection: electric.bridgePickup)
                        EnumPicker(title: "Bridge", selection: electric.bridge)
                        EnumPicker(title: "Tailpiece", selection: electric.tailpiece)
                    }
                }

                Section("Photos") {
                    if !draft.images.isEmpty {
                        photoStrip
                    }
                    LibraryPhotoPicker { localIDs in
                        draft.appendImages(localIdentifiers: localIDs)
                    }
                    #if os(iOS)
                    if CameraCapture.isAvailable {
                        Button("Take Photo", systemImage: "camera") {
                            isShowingCamera = true
                        }
                    }
                    #endif
                }
            }
            .formStyle(.grouped)
            .navigationTitle(guitar == nil ? "New Guitar" : "Edit Guitar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
            .onChange(of: draft.guitarType) { _, type in
                // Give the matching section sensible values when the type changes.
                switch type {
                case .acoustic: if draft.acoustic == nil { draft.acoustic = .standard }
                case .electric, .bass: if draft.electric == nil { draft.electric = .standard }
                case .mandolin: break
                }
            }
            #if os(iOS)
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraCapture { image in
                    Task { await saveCapturedPhoto(image) }
                }
                .ignoresSafeArea()
            }
            #endif
            .alert(
                "Photo Not Saved",
                isPresented: Binding(get: { photoError != nil }, set: { if !$0 { photoError = nil } })
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(photoError ?? "")
            }
        }
        #if os(macOS)
        .frame(minWidth: 480, minHeight: 600)
        #endif
    }

    private var photoStrip: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(draft.sortedImages) { image in
                    PhotoAssetView(image: image, targetSize: CGSize(width: 96, height: 96))
                        .frame(width: 96, height: 96)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(alignment: .topTrailing) {
                            if draft.keyImageID == image.id {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                    .padding(4)
                                    .accessibilityLabel("Key photo")
                            }
                        }
                        .contextMenu {
                            Button("Make Key Photo", systemImage: "star") {
                                draft.keyImageID = image.id
                            }
                            Button("Remove", systemImage: "trash", role: .destructive) {
                                draft.removeImage(image)
                            }
                        }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var hasAcoustic: Binding<Bool> {
        Binding(
            get: { draft.acoustic != nil },
            set: { draft.acoustic = $0 ? (draft.acoustic ?? .standard) : nil }
        )
    }

    private var hasElectric: Binding<Bool> {
        Binding(
            get: { draft.electric != nil },
            set: { draft.electric = $0 ? (draft.electric ?? .standard) : nil }
        )
    }

    #if os(iOS)
    /// Camera photos go into the user's Photos library first; we keep only the reference.
    private func saveCapturedPhoto(_ image: UIImage) async {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }
        do {
            let localID = try await PhotoLibrary.saveImage(data: data)
            draft.appendImages(localIdentifiers: [localID])
        } catch {
            photoError = error.localizedDescription
        }
    }
    #endif

    private func save() {
        if let guitar {
            draft.apply(to: guitar)
        } else {
            let newGuitar = Guitar()
            draft.apply(to: newGuitar)
            modelContext.insert(newGuitar)
            appState.selection = newGuitar
        }
        dismiss()
    }
}

/// A picker over every case of one of the model enums, showing its raw value.
struct EnumPicker<Value>: View
where Value: CaseIterable & Hashable & RawRepresentable, Value.RawValue == String, Value.AllCases: RandomAccessCollection {
    let title: String
    @Binding var selection: Value

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(Value.allCases, id: \.self) { value in
                Text(value.rawValue).tag(value)
            }
        }
    }
}

/// Same as `EnumPicker`, with a "None" choice for optional parts.
struct OptionalEnumPicker<Value>: View
where Value: CaseIterable & Hashable & RawRepresentable, Value.RawValue == String, Value.AllCases: RandomAccessCollection {
    let title: String
    @Binding var selection: Value?

    var body: some View {
        Picker(title, selection: $selection) {
            Text("None").tag(Value?.none)
            ForEach(Value.allCases, id: \.self) { value in
                Text(value.rawValue).tag(Value?.some(value))
            }
        }
    }
}

#Preview("New") {
    GuitarEditorView(guitar: nil)
        .environment(AppState())
        .modelContainer(.preview)
}
