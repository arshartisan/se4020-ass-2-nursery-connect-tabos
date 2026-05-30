//
//  IncidentService.swift
//  NurseryConnect-TabOS
//
//  Owns incident persistence + the simulated manager dispatch (carried
//  forward from A1).
//
//  EYFS / Children Act 1989: validates, persists with a system-stamped
//  submittedAt, then awaits MockDispatchService to simulate manager routing.
//  There is deliberately NO update/delete API — submitted incidents are
//  immutable (safeguarding audit trail).
//

import Foundation
import SwiftData

enum IncidentServiceError: LocalizedError {
    case invalidReport(reason: String)
    case persistenceFailure(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidReport(let reason):
            return "Incident report is invalid: \(reason)"
        case .persistenceFailure(let error):
            return "Could not submit incident: \(error.localizedDescription)"
        }
    }
}

@MainActor
struct IncidentService {
    let context: ModelContext
    var dispatchService = MockDispatchService()

    /// Validates → persists → simulates manager dispatch → marks dispatched.
    func submit(_ report: IncidentReport) async throws {
        try validate(report)
        report.submittedAt = .now
        context.insert(report)
        do {
            try context.save()
        } catch {
            throw IncidentServiceError.persistenceFailure(underlying: error)
        }

        // Simulate onward routing to the setting manager.
        await dispatchService.dispatch(incidentID: report.id)
        report.dispatchStatus = .dispatched
        try? context.save()
    }

    /// All incidents across every child, newest first.
    func allIncidents() throws -> [IncidentReport] {
        let descriptor = FetchDescriptor<IncidentReport>(
            sortBy: [SortDescriptor(\.submittedAt, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            throw IncidentServiceError.persistenceFailure(underlying: error)
        }
    }

    // MARK: - Validation

    private func validate(_ report: IncidentReport) throws {
        if report.descriptionText.trimmed.isEmpty {
            throw IncidentServiceError.invalidReport(reason: "Describe what happened.")
        }
        if report.immediateActionTaken.trimmed.isEmpty {
            throw IncidentServiceError.invalidReport(reason: "Record the immediate action taken.")
        }
    }
}
