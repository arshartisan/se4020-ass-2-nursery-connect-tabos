//
//  DiaryService.swift
//  NurseryConnect-TabOS
//
//  Owns all diary persistence (carried forward from A1). @MainActor-isolated
//  for SwiftData safety; exposes a strongly-typed LocalizedError; separates
//  validation from persistence; every failure mode is explicit.
//

import Foundation
import SwiftData

enum DiaryServiceError: LocalizedError {
    case invalidEntry(reason: String)
    case persistenceFailure(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidEntry(let reason):
            return "Diary entry is invalid: \(reason)"
        case .persistenceFailure(let error):
            return "Could not save diary entry: \(error.localizedDescription)"
        }
    }
}

@MainActor
struct DiaryService {
    let context: ModelContext

    /// Saves a new diary entry. Throws if validation or persistence fails.
    func save(_ entry: DiaryEntry) async throws {
        try validate(entry)
        context.insert(entry)
        do {
            try context.save()
        } catch {
            throw DiaryServiceError.persistenceFailure(underlying: error)
        }
    }

    /// All entries for a child, newest first.
    func entries(for child: Child) throws -> [DiaryEntry] {
        let childID = child.id
        let descriptor = FetchDescriptor<DiaryEntry>(
            predicate: #Predicate { $0.child?.id == childID },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            throw DiaryServiceError.persistenceFailure(underlying: error)
        }
    }

    // MARK: - Validation (type-specific)

    private func validate(_ entry: DiaryEntry) throws {
        switch entry.type {
        case .activity:
            if (entry.activityName ?? "").trimmed.isEmpty && entry.notes.trimmed.isEmpty {
                throw DiaryServiceError.invalidEntry(reason: "Add an activity name or a note.")
            }
        case .meal:
            if entry.mealType == nil {
                throw DiaryServiceError.invalidEntry(reason: "Choose a meal type.")
            }
        case .nap:
            guard let start = entry.napStart, let end = entry.napEnd else {
                throw DiaryServiceError.invalidEntry(reason: "Set both nap start and end times.")
            }
            if end <= start {
                throw DiaryServiceError.invalidEntry(reason: "Nap end must be after the start.")
            }
        case .nappy:
            if entry.nappyType == nil {
                throw DiaryServiceError.invalidEntry(reason: "Choose a nappy type.")
            }
        case .wellbeing:
            if entry.wellbeingMood == nil {
                throw DiaryServiceError.invalidEntry(reason: "Pick a wellbeing mood.")
            }
        }
    }
}

extension String {
    /// Whitespace-trimmed copy (shared helper).
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
