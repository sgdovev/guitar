//
//  GuitarsApp.swift
//  Guitars
//
//  Created by Bob Nickolopoulos on 10/13/26.
//

import SwiftData
import SwiftUI

@main
struct GuitarsApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
        }
        .modelContainer(for: [Guitar.self, Tombstone.self])
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Guitar") {
                    appState.isAddingGuitar = true
                }
                .keyboardShortcut("n")

                Button("Import Inventory…") {
                    appState.isImporting = true
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])
            }
        }
    }
}
