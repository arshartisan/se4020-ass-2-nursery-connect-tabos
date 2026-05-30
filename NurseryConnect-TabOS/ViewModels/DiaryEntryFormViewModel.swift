//
//  DiaryEntryFormViewModel.swift
//  NurseryConnect-TabOS
//
//  Form state-machine for a single diary entry (all five types). The Save
//  button binds to `isValid`; `save()` is an async flow that wraps the
//  service error for display. @Observable @MainActor.
//

import Foundation
import Observation

@Observable
@MainActor
final class DiaryEntryFormViewModel: Identifiable {

    enum SaveState: Equatable {
        case idle, saving, saved, failed(String)
    }

    let id = UUID()
    let child: Child
    let type: DiaryEntryType

    // Shared
    var timestamp: Date = .now
    var notes: String = ""

    // Activity
    var activityName: String = ""
    // Meal
    var mealType: MealType = .lunch
    var mealAmount: MealAmount = .most
    // Nap
    var napStart: Date = .now
    var napEnd: Date = Date().addingTimeInterval(60 * 60)
    // Nappy
    var nappyType: NappyType = .wet
    // Wellbeing
    var wellbeingMood: WellbeingMood = .okay

    var saveState: SaveState = .idle
    var errorMessage: String?

    var isSaving: Bool { saveState == .saving }

    private let diaryService: DiaryService

    init(child: Child, type: DiaryEntryType, diaryService: DiaryService) {
        self.child = child
        self.type = type
        self.diaryService = diaryService
    }

    /// Client-side validity used to enable the Save button.
    var isValid: Bool {
        switch type {
        case .activity:  return !activityName.trimmed.isEmpty || !notes.trimmed.isEmpty
        case .meal:      return true
        case .nap:       return napEnd > napStart
        case .nappy:     return true
        case .wellbeing: return true
        }
    }

    func save() async -> Bool {
        saveState = .saving
        errorMessage = nil

        let entry = DiaryEntry(type: type, timestamp: timestamp,
                               loggedByKeyworker: SeedDataService.currentKeyworker,
                               notes: notes.trimmed, child: child)
        switch type {
        case .activity:
            entry.activityName = activityName.trimmed
        case .meal:
            entry.mealType = mealType
            entry.mealAmount = mealAmount
        case .nap:
            entry.napStart = napStart
            entry.napEnd = napEnd
        case .nappy:
            entry.nappyType = nappyType
        case .wellbeing:
            entry.wellbeingMood = wellbeingMood
        }

        do {
            try await diaryService.save(entry)
            Haptics.success()
            saveState = .saved
            return true
        } catch {
            Haptics.error()
            errorMessage = error.localizedDescription
            saveState = .failed(error.localizedDescription)
            return false
        }
    }
}
