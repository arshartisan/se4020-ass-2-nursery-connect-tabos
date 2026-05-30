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

        for child in makeRoster() {
            context.insert(child)
        }
        try? context.save()
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
