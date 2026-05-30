//
//  NurseryConnect_TabOSApp.swift
//  NurseryConnect-TabOS
//
//  iPadOS extension of the Assignment 1 NurseryConnect Keyworker app.
//  Launches straight into its main functionality — no login / auth
//  (assignment brief rule).
//

import SwiftUI
import SwiftData

@main
struct NurseryConnect_TabOSApp: App {

    /// The single production SwiftData container, attached to the whole
    /// view hierarchy via `.modelContainer(_:)`.
    private let modelContainer = ModelContainerProvider.makeProductionContainer()

    init() {
        // Seed the roster on first launch so every screen is non-empty.
        SeedDataService.seedIfNeeded(modelContainer.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            RootSplitView()
        }
        .modelContainer(modelContainer)
    }
}
