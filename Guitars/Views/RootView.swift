//
//  RootView.swift
//  Guitars
//

import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

/// Picks the layout for the current window and handles incoming
/// `.guitarinventory` files (AirDrop, Files, Finder, or File > Import).
struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif

    @State private var importMessage: String?

    var body: some View {
        @Bindable var appState = appState

        GeometryReader { proxy in
            let mode = layoutMode(for: proxy.size)
            layout(for: mode)
                .environment(\.layoutMode, mode)
        }
        .onOpenURL { url in
            importInventory(from: url)
        }
        .fileImporter(isPresented: $appState.isImporting, allowedContentTypes: [.guitarInventory]) { result in
            switch result {
            case .success(let url): importInventory(from: url)
            case .failure(let error): importMessage = error.localizedDescription
            }
        }
        .sheet(isPresented: $appState.isAddingGuitar) {
            GuitarEditorView(guitar: nil)
        }
        .alert(
            "Guitar Inventory",
            isPresented: Binding(get: { importMessage != nil }, set: { if !$0 { importMessage = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importMessage ?? "")
        }
    }

    @ViewBuilder
    private func layout(for mode: LayoutMode) -> some View {
        switch mode {
        case .compact:
            CompactLayout()
        case .compactLandscape:
            SideBySideLayout()
        case .regularPortrait, .regularLandscape, .desktop:
            SplitLayout(mode: mode)
        }
    }

    private func layoutMode(for size: CGSize) -> LayoutMode {
        #if os(macOS)
        .desktop
        #else
        LayoutMode.resolve(
            size: size,
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
        #endif
    }

    private func importInventory(from url: URL) {
        guard url.pathExtension == UTType.guitarInventory.preferredFilenameExtension else { return }
        // The import can delete the guitar on screen, so let go of it first.
        appState.selection = nil
        do {
            importMessage = try SyncMerger.importFile(at: url, into: modelContext).message
        } catch {
            importMessage = "Couldn't import that file. \(error.localizedDescription)"
        }
    }
}

#Preview {
    RootView()
        .environment(AppState())
        .modelContainer(.preview)
}
