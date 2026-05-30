//
//  ModelContainerProvider.swift
//  NurseryConnect-TabOS
//
//  Single source of truth for the SwiftData stack (carried forward from A1).
//  Exposes two factories: an on-disk production container used by the app,
//  and an in-memory container used by SwiftUI previews and the test suite.
//
//  Production hardening NOTE (regulatory): a real childcare deployment would
//  set FileProtectionType.complete on this store so child records are
//  encrypted at rest (UK GDPR Art. 32 / Art. 25 data-protection-by-design).
//

import SwiftData

enum ModelContainerProvider {

    /// Every @Model type in the app.
    static let schema = Schema([
        Child.self,
        DiaryEntry.self,
        IncidentReport.self
    ])

    /// On-disk container for the running app.
    static func makeProductionContainer() -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create production ModelContainer: \(error)")
        }
    }

    /// Ephemeral container for previews + unit tests — never touches disk.
    static func makeInMemoryContainer() -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create in-memory ModelContainer: \(error)")
        }
    }
}
