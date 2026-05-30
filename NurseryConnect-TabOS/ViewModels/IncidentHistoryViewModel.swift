//
//  IncidentHistoryViewModel.swift
//  NurseryConnect-TabOS
//
//  Drives the cross-child incident history (audit trail). Loads via
//  IncidentService and applies a date filter. @Observable @MainActor.
//

import Foundation
import Observation

@Observable
@MainActor
final class IncidentHistoryViewModel {

    enum Filter: String, CaseIterable, Identifiable {
        case all, today, week
        var id: String { rawValue }
        var title: String {
            switch self {
            case .all:   return "All"
            case .today: return "Today"
            case .week:  return "This week"
            }
        }
    }

    private(set) var allReports: [IncidentReport] = []
    var filter: Filter = .all
    var selectedID: IncidentReport.ID?
    var errorMessage: String?

    private let service: IncidentService

    init(service: IncidentService) {
        self.service = service
    }

    func load() {
        do {
            allReports = try service.allIncidents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var filtered: [IncidentReport] {
        let cal = Calendar.current
        switch filter {
        case .all:
            return allReports
        case .today:
            return allReports.filter { cal.isDateInToday($0.submittedAt) }
        case .week:
            guard let weekAgo = cal.date(byAdding: .day, value: -7, to: .now) else { return allReports }
            return allReports.filter { $0.submittedAt >= weekAgo }
        }
    }

    var selected: IncidentReport? {
        guard let id = selectedID else { return nil }
        return allReports.first { $0.id == id }
    }
}
