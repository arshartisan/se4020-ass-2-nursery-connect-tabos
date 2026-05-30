//
//  SeedDataService.swift
//  NurseryConnect-TabOS
//
//  Idempotently seeds a fictional roster so every screen is non-empty at
//  launch (no dead blank canvas). Carried forward from A1.
//
//  Phase 3: seeds the child roster only. Phase 4 extends this to seed sample
//  diary entries + an incident or two so the timeline and charts have data.
//

import Foundation
import SwiftData

@MainActor
enum SeedDataService {

    /// The single keyworker this MVP is scoped to (no auth — brief rule).
    static let currentKeyworker = "Sarah Mitchell"

    /// Seeds the store only if it is empty (safe to call on every launch).
    static func seedIfNeeded(_ context: ModelContext) {
        let existing = try? context.fetchCount(FetchDescriptor<Child>())
        guard (existing ?? 0) == 0 else { return }

        let roster = makeRoster()
        for child in roster {
            context.insert(child)
            seedDiary(for: child)
        }
        seedIncidents(for: roster)
        try? context.save()
    }

    // MARK: - Diary seed (gives the Phase 6 charts real data)

    private static func seedDiary(for child: Child) {
        let cal = Calendar.current
        // Spread entries across the last 7 days.
        for dayOffset in 0..<7 {
            guard let day = cal.date(byAdding: .day, value: -dayOffset, to: .now) else { continue }

            // Wellbeing mood — gently varies per child + day for a readable trend.
            let moodValue = 3 + ((child.avatarSeed + dayOffset) % 3) - ((dayOffset % 2 == 0) ? 0 : 1)
            let mood = WellbeingMood(rawValue: max(1, min(5, moodValue))) ?? .okay
            let wellbeing = DiaryEntry(type: .wellbeing, timestamp: at(day, 9, 30, cal),
                                       loggedByKeyworker: currentKeyworker, child: child)
            wellbeing.wellbeingMood = mood

            // Nap — 60–110 min depending on child/day.
            let napMinutes = 60 + ((child.avatarSeed * 7 + dayOffset * 11) % 50)
            let napStart = at(day, 12, 30, cal)
            let nap = DiaryEntry(type: .nap, timestamp: napStart,
                                 loggedByKeyworker: currentKeyworker, child: child)
            nap.napStart = napStart
            nap.napEnd = cal.date(byAdding: .minute, value: napMinutes, to: napStart)

            // Lunch — amount varies.
            let amount: MealAmount = [.all, .most, .some, .all][(child.avatarSeed + dayOffset) % 4]
            let meal = DiaryEntry(type: .meal, timestamp: at(day, 12, 0, cal),
                                  loggedByKeyworker: currentKeyworker, child: child)
            meal.mealType = .lunch
            meal.mealAmount = amount

            // An activity most days.
            if dayOffset % 2 == 0 {
                let names = ["Water play", "Story circle", "Painting", "Garden time", "Music & movement"]
                let activity = DiaryEntry(type: .activity, timestamp: at(day, 10, 15, cal),
                                          loggedByKeyworker: currentKeyworker,
                                          notes: "Engaged well with peers.", child: child)
                activity.activityName = names[(child.avatarSeed + dayOffset) % names.count]
                child.diaryEntries.append(activity)
            }

            child.diaryEntries.append(contentsOf: [wellbeing, nap, meal])
        }
    }

    // MARK: - Incident seed (one example so the history screen is non-empty)

    private static func seedIncidents(for roster: [Child]) {
        guard let child = roster.first else { return }
        let cal = Calendar.current
        let occurred = cal.date(byAdding: .day, value: -2, to: .now) ?? .now
        let incident = IncidentReport(
            child: child,
            category: .minorAccident,
            severity: .low,
            occurredAt: at(occurred, 14, 20, cal),
            location: "Sunflower Room — soft play area",
            descriptionText: "Tripped on a play mat and bumped their left knee. Brief cry, settled quickly.",
            immediateActionTaken: "Comforted, applied a cold compress, monitored for swelling. No further concern.",
            witnesses: "Sarah Mitchell, Priya Devi",
            bodyMapRegions: [.leftLeg],
            loggedByKeyworker: currentKeyworker,
            submittedAt: at(occurred, 14, 35, cal),
            dispatchStatus: .dispatched
        )
        child.incidentReports.append(incident)
    }

    /// Helper: a Date on `day` at the given hour/minute.
    private static func at(_ day: Date, _ hour: Int, _ minute: Int, _ cal: Calendar) -> Date {
        cal.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    /// Six fictional children assigned to the current keyworker.
    private static func makeRoster() -> [Child] {
        func dob(years: Int, months: Int) -> Date {
            Calendar.current.date(byAdding: DateComponents(year: -years, month: -months), to: .now) ?? .now
        }

        return [
            Child(firstName: "Ava", lastName: "Thompson", dateOfBirth: dob(years: 2, months: 4),
                  roomName: "Sunflower", keyworkerName: currentKeyworker,
                  allergies: ["Peanuts"], dietaryNotes: "Vegetarian",
                  photographyConsent: true, avatarSeed: 0),
            Child(firstName: "Noah", lastName: "Patel", dateOfBirth: dob(years: 3, months: 1),
                  roomName: "Sunflower", keyworkerName: currentKeyworker,
                  allergies: [], dietaryNotes: "",
                  photographyConsent: false, avatarSeed: 1),
            Child(firstName: "Mia", lastName: "Okafor", dateOfBirth: dob(years: 1, months: 8),
                  roomName: "Bluebell", keyworkerName: currentKeyworker,
                  allergies: ["Dairy", "Egg"], dietaryNotes: "Lactose-free formula",
                  photographyConsent: true, avatarSeed: 2),
            Child(firstName: "Leo", lastName: "Nakamura", dateOfBirth: dob(years: 2, months: 11),
                  roomName: "Bluebell", keyworkerName: currentKeyworker,
                  allergies: [], dietaryNotes: "Halal",
                  photographyConsent: true, avatarSeed: 3),
            Child(firstName: "Sofia", lastName: "Rossi", dateOfBirth: dob(years: 3, months: 6),
                  roomName: "Sunflower", keyworkerName: currentKeyworker,
                  allergies: ["Gluten"], dietaryNotes: "Coeliac",
                  photographyConsent: true, avatarSeed: 4),
            Child(firstName: "Ethan", lastName: "Walsh", dateOfBirth: dob(years: 1, months: 5),
                  roomName: "Bluebell", keyworkerName: currentKeyworker,
                  allergies: [], dietaryNotes: "",
                  photographyConsent: false, avatarSeed: 5)
        ]
    }
}
