//
//  ChildDetailViewModel.swift
//  NurseryConnect-TabOS
//
//  Drives the child day-view: loads the diary timeline and refreshes it after
//  a save. @Observable @MainActor; never touches SwiftData directly.
//

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class ChildDetailViewModel {

    let child: Child
    private(set) var entries: [DiaryEntry] = []
    var errorMessage: String?

    /// Set true briefly after a successful diary save so the view can show a
    /// confirmation toast (and only then — never on a no-op dismiss).
    var showSavedToast = false

    private let diaryService: DiaryService

    init(child: Child, diaryService: DiaryService) {
        self.child = child
        self.diaryService = diaryService
    }

    func loadEntries() {
        do {
            entries = try diaryService.entries(for: child)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Called from the diary sheet's onDismiss with whether a save happened.
    func diaryFormDismissed(didSave: Bool) {
        guard didSave else { return }
        loadEntries()
        showSavedToast = true
    }

    /// Build a fresh form view model for a new entry of `type`.
    func makeDiaryFormViewModel(type: DiaryEntryType) -> DiaryEntryFormViewModel {
        DiaryEntryFormViewModel(child: child, type: type, diaryService: diaryService)
    }
}
