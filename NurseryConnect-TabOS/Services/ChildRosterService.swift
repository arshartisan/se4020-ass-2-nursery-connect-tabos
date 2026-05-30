//
//  ChildRosterService.swift
//  NurseryConnect-TabOS
//
//  Owns all roster reads. Carried forward from A1.
//
//  GDPR Art. 5(1)(c) DATA MINIMISATION: fetchAssignedChildren filters on
//  keyworkerName so a keyworker can only ever load the children they are
//  assigned to — purpose-limited access enforced at the service boundary.
//
//  Architecture rule (criterion 5): Views never query SwiftData directly;
//  ViewModels delegate here; the Service owns the FetchDescriptor.
//

import Foundation
import SwiftData

enum ChildRosterError: LocalizedError {
    case fetchFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "Could not load the child roster: \(error.localizedDescription)"
        }
    }
}

@MainActor
struct ChildRosterService {
    let context: ModelContext

    /// Children assigned to `keyworker`, sorted by first name.
    func fetchAssignedChildren(for keyworker: String) throws -> [Child] {
        // Extract the value into a local `let` before the #Predicate closure
        // (well-known SwiftData capture gotcha).
        let name = keyworker
        let descriptor = FetchDescriptor<Child>(
            predicate: #Predicate { $0.keyworkerName == name },
            sortBy: [SortDescriptor(\.firstName, order: .forward)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            throw ChildRosterError.fetchFailed(underlying: error)
        }
    }
}
