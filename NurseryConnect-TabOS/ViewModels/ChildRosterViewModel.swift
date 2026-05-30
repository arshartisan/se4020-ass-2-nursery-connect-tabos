//
//  ChildRosterViewModel.swift
//  NurseryConnect-TabOS
//
//  Example @Observable @MainActor view model (criterion 5). Drives the roster
//  sidebar/list. Views consume it via @Bindable; it never touches SwiftData
//  directly — it delegates to ChildRosterService.
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class ChildRosterViewModel {

    /// Explicit, testable load state machine (no silent failures).
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private(set) var children: [Child] = []
    private(set) var state: LoadState = .idle
    var errorMessage: String?

    /// Currently selected child id (drives the NavigationSplitView detail column).
    var selectedChildID: Child.ID?

    /// Live roster search text (⌘F focuses the field, see RootSplitView).
    var searchText: String = ""

    private let service: ChildRosterService
    private let keyworker: String

    init(service: ChildRosterService, keyworker: String = SeedDataService.currentKeyworker) {
        self.service = service
        self.keyworker = keyworker
    }

    var selectedChild: Child? {
        guard let id = selectedChildID else { return nil }
        return children.first { $0.id == id }
    }

    /// Children filtered by the search text (name or room), case-insensitive.
    var filteredChildren: [Child] {
        let query = searchText.trimmed
        guard !query.isEmpty else { return children }
        return children.filter {
            $0.fullName.localizedCaseInsensitiveContains(query)
                || $0.roomName.localizedCaseInsensitiveContains(query)
        }
    }

    func load() {
        state = .loading
        do {
            children = try service.fetchAssignedChildren(for: keyworker)
            state = .loaded
        } catch {
            errorMessage = error.localizedDescription
            state = .failed(error.localizedDescription)
        }
    }
}
