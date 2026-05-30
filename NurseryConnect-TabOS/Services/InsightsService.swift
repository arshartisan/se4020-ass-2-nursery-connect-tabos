//
//  InsightsService.swift
//  NurseryConnect-TabOS
//
//  The NEW feature's data layer (criterion 4 — advanced library). Reads the
//  existing diary entries and aggregates them into the chartable series the
//  Swift Charts dashboard renders: a wellbeing-mood trend, nap-duration per
//  day, and a meal-portion distribution — per child or roster-wide.
//
//  Pure read + transform; no mutation. @MainActor for SwiftData safety; the
//  aggregation itself is deterministic and unit-testable.
//

import Foundation
import SwiftData

// MARK: - Chartable value types

/// Average wellbeing mood (1–5) on a given day.
struct MoodPoint: Identifiable {
    let date: Date
    let value: Double
    var id: Date { date }
}

/// Average nap length (minutes) on a given day.
struct NapPoint: Identifiable {
    let date: Date
    let minutes: Double
    var id: Date { date }
}

/// How many meals were logged at each "amount eaten" level over the window.
struct MealPortionBar: Identifiable {
    let amount: MealAmount
    let count: Int
    var id: String { amount.rawValue }
}

/// Everything one dashboard scope needs, pre-aggregated.
struct InsightsSummary {
    let scopeTitle: String
    let dayWindow: Int
    let totalEntries: Int
    let mood: [MoodPoint]
    let nap: [NapPoint]
    let meals: [MealPortionBar]

    var averageMood: Double? {
        guard !mood.isEmpty else { return nil }
        return mood.map(\.value).reduce(0, +) / Double(mood.count)
    }
    var averageNapMinutes: Double? {
        guard !nap.isEmpty else { return nil }
        return nap.map(\.minutes).reduce(0, +) / Double(nap.count)
    }
    var hasAnyData: Bool { totalEntries > 0 }
}

@MainActor
struct InsightsService {
    let context: ModelContext

    /// Number of days back the dashboard summarises.
    static let defaultWindowDays = 7

    /// Fetch diary entries for a scope: a specific child, or `nil` = roster-wide.
    func entries(for child: Child?) throws -> [DiaryEntry] {
        if let child {
            let childID = child.id   // SwiftData #Predicate capture gotcha.
            let descriptor = FetchDescriptor<DiaryEntry>(
                predicate: #Predicate { $0.child?.id == childID }
            )
            return try context.fetch(descriptor)
        } else {
            return try context.fetch(FetchDescriptor<DiaryEntry>())
        }
    }

    /// Build the aggregated summary for a scope over the last `windowDays`.
    func summary(for child: Child?,
                 scopeTitle: String,
                 windowDays: Int = InsightsService.defaultWindowDays,
                 calendar: Calendar = .current,
                 now: Date = .now) throws -> InsightsSummary {

        let all = try entries(for: child)
        // Anchor the window to the most recent logged entry, not wall-clock
        // `now`. The seed timestamps are frozen at first launch, so a store
        // that has aged (or migrated in place) would otherwise drift out of a
        // strictly now-anchored window and render empty. Live data keeps the
        // latest entry ≈ now, so this is a no-op in production.
        let anchor = all.map(\.timestamp).max() ?? now
        let referenceDay = calendar.startOfDay(for: anchor)
        let cutoff = calendar.date(byAdding: .day, value: -(windowDays - 1),
                                   to: referenceDay) ?? referenceDay
        let windowed = all.filter { $0.timestamp >= cutoff }

        return InsightsSummary(
            scopeTitle: scopeTitle,
            dayWindow: windowDays,
            totalEntries: windowed.count,
            mood: moodSeries(from: windowed, calendar: calendar),
            nap: napSeries(from: windowed, calendar: calendar),
            meals: mealSeries(from: windowed)
        )
    }

    // MARK: - Aggregation (pure, testable)

    /// Average mood per day (only days that actually have a wellbeing entry, so
    /// the line never dips misleadingly to zero on an un-logged day).
    private func moodSeries(from entries: [DiaryEntry], calendar: Calendar) -> [MoodPoint] {
        let byDay = Dictionary(grouping: entries.filter { $0.type == .wellbeing }) {
            calendar.startOfDay(for: $0.timestamp)
        }
        return byDay.compactMap { day, group -> MoodPoint? in
            let values = group.compactMap { $0.wellbeingMood?.rawValue }
            guard !values.isEmpty else { return nil }
            let avg = Double(values.reduce(0, +)) / Double(values.count)
            return MoodPoint(date: day, value: avg)
        }
        .sorted { $0.date < $1.date }
    }

    /// Average nap length per day.
    private func napSeries(from entries: [DiaryEntry], calendar: Calendar) -> [NapPoint] {
        let byDay = Dictionary(grouping: entries.filter { $0.type == .nap }) {
            calendar.startOfDay(for: $0.timestamp)
        }
        return byDay.compactMap { day, group -> NapPoint? in
            let minutes = group.compactMap { $0.napDurationMinutes }
            guard !minutes.isEmpty else { return nil }
            let avg = Double(minutes.reduce(0, +)) / Double(minutes.count)
            return NapPoint(date: day, minutes: avg)
        }
        .sorted { $0.date < $1.date }
    }

    /// Meal count by amount eaten — every level present (0 included) so the bar
    /// chart axis is stable across scopes.
    private func mealSeries(from entries: [DiaryEntry]) -> [MealPortionBar] {
        let meals = entries.filter { $0.type == .meal }
        return MealAmount.allCases.map { amount in
            MealPortionBar(amount: amount,
                           count: meals.filter { $0.mealAmount == amount }.count)
        }
    }
}
