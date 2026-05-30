//
//  PreviewData.swift
//  NurseryConnect-TabOS
//
//  Shared in-memory container for SwiftUI previews — seeded so previews are
//  never empty. Uses the same ModelContainerProvider + SeedDataService the
//  app and tests use.
//

import SwiftData

@MainActor
enum PreviewData {
    /// A seeded in-memory container for use in `#Preview` blocks.
    static let container: ModelContainer = {
        let container = ModelContainerProvider.makeInMemoryContainer()
        SeedDataService.seedIfNeeded(container.mainContext)
        return container
    }()
}
