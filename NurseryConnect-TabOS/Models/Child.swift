//
//  Child.swift
//  NurseryConnect-TabOS
//
//  Carried forward from Assignment 1 (re-platformed for iPad).
//
//  GDPR Art. 5(1)(c) data minimisation: a Child is only ever loaded for the
//  keyworker it is assigned to — see ChildRosterService.fetchAssignedChildren.
//
//  NOTE: In Phase 3 this is the minimal display model. Phase 4 adds the
//  cascade-delete relationships to DiaryEntry and IncidentReport.
//

import Foundation
import SwiftData

@Model
final class Child {
    /// Stable identifier (used in #Predicate queries — see services).
    var id: UUID
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var roomName: String

    /// Named keyworker (EYFS 2024 assigned-keyworker duty). The roster query
    /// filters on this so a keyworker only ever sees their own children.
    var keyworkerName: String

    /// Safety-critical: surfaced as an unmissable danger chip on the detail screen.
    var allergies: [String]
    var dietaryNotes: String

    /// Consent (GDPR Art. 6(1)(a)) — the ONLY thing consent is relied on for.
    /// Rendered as a red camera badge when `false`.
    var photographyConsent: Bool

    /// Optional avatar tint seed so cards look distinct without real photos.
    var avatarSeed: Int

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        dateOfBirth: Date,
        roomName: String,
        keyworkerName: String,
        allergies: [String] = [],
        dietaryNotes: String = "",
        photographyConsent: Bool = true,
        avatarSeed: Int = 0
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.roomName = roomName
        self.keyworkerName = keyworkerName
        self.allergies = allergies
        self.dietaryNotes = dietaryNotes
        self.photographyConsent = photographyConsent
        self.avatarSeed = avatarSeed
    }
}

// MARK: - Derived display helpers (pure computed properties only)

extension Child {
    var fullName: String { "\(firstName) \(lastName)" }

    var initials: String {
        let f = firstName.first.map(String.init) ?? ""
        let l = lastName.first.map(String.init) ?? ""
        return (f + l).uppercased()
    }

    /// Age expressed as years + months, e.g. "2y 4m".
    var ageDescription: String {
        let comps = Calendar.current.dateComponents([.year, .month], from: dateOfBirth, to: .now)
        let years = comps.year ?? 0
        let months = comps.month ?? 0
        return "\(years)y \(months)m"
    }

    var hasAllergies: Bool { !allergies.isEmpty }
}
