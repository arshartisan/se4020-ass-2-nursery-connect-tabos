//
//  DiaryEntry.swift
//  NurseryConnect-TabOS
//
//  Carried forward from Assignment 1. A single @Model carries nullable
//  type-specific fields rather than five subclasses — favours SwiftData
//  ergonomics over class-hierarchy purity (A1 design decision).
//
//  EYFS 2024: the five entry types map to the daily-observation categories a
//  nursery must record. Every entry is timestamped + attributed to a named
//  keyworker (Ofsted audit / GDPR accuracy).
//

import Foundation
import SwiftData

@Model
final class DiaryEntry {
    var id: UUID
    var timestamp: Date
    var typeRaw: String
    var loggedByKeyworker: String
    var notes: String

    // Activity
    var activityName: String?
    // Meal
    var mealTypeRaw: String?
    var mealAmountRaw: String?
    // Nap
    var napStart: Date?
    var napEnd: Date?
    // Nappy
    var nappyTypeRaw: String?
    // Wellbeing
    var wellbeingMoodRaw: Int?

    /// Inverse of `Child.diaryEntries` (cascade delete from the Child side).
    var child: Child?

    init(
        id: UUID = UUID(),
        type: DiaryEntryType,
        timestamp: Date = .now,
        loggedByKeyworker: String,
        notes: String = "",
        child: Child? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.typeRaw = type.rawValue
        self.loggedByKeyworker = loggedByKeyworker
        self.notes = notes
        self.child = child
    }
}

// MARK: - Typed accessors over the raw stored values

extension DiaryEntry {
    var type: DiaryEntryType {
        get { DiaryEntryType(rawValue: typeRaw) ?? .activity }
        set { typeRaw = newValue.rawValue }
    }

    var mealType: MealType? {
        get { mealTypeRaw.flatMap(MealType.init(rawValue:)) }
        set { mealTypeRaw = newValue?.rawValue }
    }

    var mealAmount: MealAmount? {
        get { mealAmountRaw.flatMap(MealAmount.init(rawValue:)) }
        set { mealAmountRaw = newValue?.rawValue }
    }

    var nappyType: NappyType? {
        get { nappyTypeRaw.flatMap(NappyType.init(rawValue:)) }
        set { nappyTypeRaw = newValue?.rawValue }
    }

    var wellbeingMood: WellbeingMood? {
        get { wellbeingMoodRaw.flatMap(WellbeingMood.init(rawValue:)) }
        set { wellbeingMoodRaw = newValue?.rawValue }
    }

    /// Nap length in minutes (nil unless both ends are set & ordered).
    var napDurationMinutes: Int? {
        guard let start = napStart, let end = napEnd, end > start else { return nil }
        return Int(end.timeIntervalSince(start) / 60)
    }

    /// A short one-line summary used in the timeline row.
    var summary: String {
        switch type {
        case .activity: return activityName ?? "Activity"
        case .meal:
            let m = mealType?.title ?? "Meal"
            if let a = mealAmount?.title { return "\(m) · \(a)" }
            return m
        case .nap:
            if let mins = napDurationMinutes { return "Nap · \(mins) min" }
            return "Nap"
        case .nappy: return nappyType?.title ?? "Nappy change"
        case .wellbeing: return wellbeingMood?.title ?? "Wellbeing"
        }
    }
}

// MARK: - Enums

enum DiaryEntryType: String, CaseIterable, Identifiable, Codable {
    case activity, meal, nap, nappy, wellbeing
    var id: String { rawValue }

    var title: String {
        switch self {
        case .activity:  return "Activity"
        case .meal:      return "Meal"
        case .nap:       return "Nap"
        case .nappy:     return "Nappy"
        case .wellbeing: return "Wellbeing"
        }
    }

    var icon: String {
        switch self {
        case .activity:  return AppIcons.activity
        case .meal:      return AppIcons.meal
        case .nap:       return AppIcons.nap
        case .nappy:     return AppIcons.nappy
        case .wellbeing: return AppIcons.wellbeing
        }
    }
}

enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast, lunch, snack, tea
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum MealAmount: String, CaseIterable, Identifiable, Codable {
    case none, some, most, all
    var id: String { rawValue }
    var title: String {
        switch self {
        case .none: return "Ate none"
        case .some: return "Ate some"
        case .most: return "Ate most"
        case .all:  return "Ate all"
        }
    }
}

enum NappyType: String, CaseIterable, Identifiable, Codable {
    case wet, soiled, dry, both
    var id: String { rawValue }
    var title: String {
        switch self {
        case .wet:    return "Wet"
        case .soiled: return "Soiled"
        case .dry:    return "Dry"
        case .both:   return "Wet & soiled"
        }
    }
}

/// 1–5 wellbeing scale (Leuven-style). Used by the Swift Charts mood trend.
enum WellbeingMood: Int, CaseIterable, Identifiable, Codable {
    case verySad = 1, sad, okay, happy, veryHappy
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .verySad:   return "Very low"
        case .sad:       return "Low"
        case .okay:      return "Okay"
        case .happy:     return "Happy"
        case .veryHappy: return "Very happy"
        }
    }

    var emoji: String {
        switch self {
        case .verySad:   return "😢"
        case .sad:       return "🙁"
        case .okay:      return "😐"
        case .happy:     return "🙂"
        case .veryHappy: return "😄"
        }
    }
}
