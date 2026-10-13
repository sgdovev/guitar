//
//  GuitarListView.swift
//  Guitars
//

import Foundation
import SwiftData
import SwiftUI

struct GuitarListView: View {
    let filter: SidebarFilter
    /// nil in the compact layout, where rows push instead of select.
    let selection: Binding<Guitar?>?
    /// Rows are navigation links, except beside an always-visible detail pane.
    var usesLinks = true

    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Guitar.modelName) private var guitars: [Guitar]
    @State private var searchText = ""

    var body: some View {
        List(selection: selection) {
            ForEach(filteredGuitars) { guitar in
                if usesLinks {
                    NavigationLink(value: guitar) {
                        GuitarRow(guitar: guitar)
                    }
                } else {
                    GuitarRow(guitar: guitar)
                        .tag(guitar)
                }
            }
            .onDelete { offsets in
                let doomed = offsets.map { filteredGuitars[$0] }
                for guitar in doomed {
                    delete(guitar)
                }
            }
        }
        .overlay {
            if filteredGuitars.isEmpty {
                if searchText.isEmpty {
                    ContentUnavailableView {
                        Label("No Guitars", systemImage: "guitars")
                    } actions: {
                        Button("Add Guitar") { appState.isAddingGuitar = true }
                    }
                } else {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle(filter.title)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Add Guitar", systemImage: "plus") {
                    appState.isAddingGuitar = true
                }
                ShareLink(
                    item: InventoryExport(container: modelContext.container),
                    preview: SharePreview("Guitar Inventory", image: Image(systemName: "guitars"))
                ) {
                    Label("Share Inventory", systemImage: "square.and.arrow.up")
                }
                Button("Import Inventory", systemImage: "square.and.arrow.down") {
                    appState.isImporting = true
                }
            }
        }
    }

    private var filteredGuitars: [Guitar] {
        guitars.filter { guitar in
            guard filter.matches(guitar) else { return false }
            guard !searchText.isEmpty else { return true }
            return [guitar.displayName, guitar.serialNumber, String(guitar.modelYear)]
                .contains { $0.localizedStandardContains(searchText) }
        }
    }

    private func delete(_ guitar: Guitar) {
        if appState.selection == guitar {
            appState.selection = nil
        }
        modelContext.deleteGuitar(guitar)
    }
}

struct GuitarRow: View {
    let guitar: Guitar

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let keyImage = guitar.keyImage {
                    PhotoAssetView(image: keyImage, targetSize: CGSize(width: 48, height: 48))
                } else {
                    Image(systemName: "guitars")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.quaternary)
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(guitar.displayName)
                    .font(.headline)
                Text("\(String(guitar.modelYear)) · \(guitar.guitarType.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        GuitarListView(filter: .all, selection: nil)
    }
    .environment(AppState())
    .modelContainer(.preview)
}
