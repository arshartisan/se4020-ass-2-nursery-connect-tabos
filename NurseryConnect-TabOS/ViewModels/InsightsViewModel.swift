//
//  InsightsViewModel.swift
//  NurseryConnect-TabOS
//
//  Drives the Development & Wellbeing Insights dashboard. Loads the keyworker's
//  roster, then computes an InsightsSummary for the selected scope (roster-wide
//  or a single child). @Observable @MainActor; delegates all data work to
//  InsightsService / ChildRosterService.
//

import Foundation
import SwiftData
import Observation

/// What the dashboard is currently summarising.
enum InsightsScope: Hashable, Identifiable {
    case roster
    case child(Child.ID)

    var id: String {
        switch self {
        case .roster:          return "roster"
        case .child(let cid):  return cid.uuidString
        }
    }
}

@Observable
@MainActor
final class InsightsViewModel {

    enum LoadState: Equatable {
        case idle, loading, loaded
        case failed(String)
    }

    private(set) var children: [Child] = []
    private(set) var state: LoadState = .idle
    private(set) var summary: InsightsSummary?

    /// Selected scope (drives the detail column). Defaults to the roster view.
    var selectedScope: InsightsScope? = .roster {
        didSet { if selectedScope != oldValue { refreshSummary() } }
    }

    private let rosterService: ChildRosterService
    private let insightsService: InsightsService
    private let keyworker: String

    init(rosterService: ChildRosterService,
         insightsService: InsightsService,
         keyworker: String = SeedDataService.currentKeyworker) {
        self.rosterService = rosterService
        self.insightsService = insightsService
        self.keyworker = keyworker
    }

    /// The child object backing a `.child` scope (nil for roster-wide).
    func child(for scope: InsightsScope) -> Child? {
        guard case let .child(id) = scope else { return nil }
        return children.first { $0.id == id }
    }

    func load() {
        state = .loading
        do {
            children = try rosterService.fetchAssignedChildren(for: keyworker)
            state = .loaded
            refreshSummary()
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    /// Recompute the summary for the current scope.
    func refreshSummary() {
        guard let scope = selectedScope else { summary = nil; return }
        let child = self.child(for: scope)
        let title: String
        switch scope {
        case .roster:        title = "All children"
        case .child:         title = child?.fullName ?? "Child"
        }
        summary = try? insightsService.summary(for: child, scopeTitle: title)
    }
}
