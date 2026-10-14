//
//  Layouts.swift
//  Guitars
//
//  The only views that differ by layout. Everything inside them (list, detail,
//  editor) is shared.
//

import SwiftUI

/// iPhone upright or folded: one column with push navigation.
struct CompactLayout: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack(path: path) {
            GuitarListView(filter: .all, selection: nil)
                .navigationDestination(for: Guitar.self) { guitar in
                    GuitarDetailView(guitar: guitar)
                }
        }
    }

    /// The pushed guitar is the shared selection, so rotating keeps it open.
    private var path: Binding<[Guitar]> {
        Binding(
            get: { appState.selection.map { [$0] } ?? [] },
            set: { appState.selection = $0.last }
        )
    }
}

/// iPhone on its side: list on the left, detail on the right.
struct SideBySideLayout: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        HStack(spacing: 0) {
            NavigationStack {
                GuitarListView(filter: .all, selection: $appState.selection, usesLinks: false)
            }
            .frame(width: 300)

            Divider()

            NavigationStack {
                DetailColumn(guitar: appState.selection)
            }
        }
    }
}

/// iPad, unfolded phone and Mac: sidebar, list and detail.
struct SplitLayout: View {
    let mode: LayoutMode

    @Environment(AppState.self) private var appState
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        @Bindable var appState = appState

        NavigationSplitView(columnVisibility: $columnVisibility) {
            FilterSidebar(selection: $appState.filter)
        } content: {
            GuitarListView(filter: appState.filter, selection: $appState.selection)
        } detail: {
            DetailColumn(guitar: appState.selection)
        }
        .modifier(SplitStyle(mode: mode))
        .onChange(of: mode, initial: true) {
            // Portrait gives the detail the room; landscape and Mac show everything.
            columnVisibility = mode == .regularPortrait ? .doubleColumn : .all
        }
    }
}

private struct SplitStyle: ViewModifier {
    let mode: LayoutMode

    func body(content: Content) -> some View {
        if mode == .regularPortrait {
            content.navigationSplitViewStyle(.prominentDetail)
        } else {
            content.navigationSplitViewStyle(.balanced)
        }
    }
}

private struct DetailColumn: View {
    let guitar: Guitar?

    var body: some View {
        if let guitar {
            GuitarDetailView(guitar: guitar)
        } else {
            ContentUnavailableView("Select a Guitar", systemImage: "guitars")
        }
    }
}

struct FilterSidebar: View {
    @Binding var selection: SidebarFilter

    var body: some View {
        List(selection: optionalSelection) {
            NavigationLink(value: SidebarFilter.all) {
                Label(SidebarFilter.all.title, systemImage: "guitars")
            }
            Section("Brands") {
                ForEach(Brand.allCases, id: \.self) { brand in
                    NavigationLink(value: SidebarFilter.brand(brand)) {
                        Text(brand.rawValue)
                    }
                }
            }
            Section("Types") {
                ForEach(GuitarType.allCases, id: \.self) { type in
                    NavigationLink(value: SidebarFilter.type(type)) {
                        Text(type.rawValue)
                    }
                }
            }
        }
        .navigationTitle("Guitars")
    }

    private var optionalSelection: Binding<SidebarFilter?> {
        Binding(get: { selection }, set: { selection = $0 ?? .all })
    }
}
