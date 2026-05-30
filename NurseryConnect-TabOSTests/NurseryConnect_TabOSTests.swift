//
//  NurseryConnect_TabOSTests.swift
//  NurseryConnect-TabOSTests
//
//  Pure model-helper tests (no persistence needed) — the derived display logic
//  carried forward from A1.
//

import Testing
import Foundation
@testable import NurseryConnect_TabOS

@MainActor
struct ModelHelperTests {

    @Test("Child.initials takes the first letter of each name, uppercased")
    func childInitials() {
        let child = TestSupport.child(first: "ava", last: "thompson")
        #expect(child.initials == "AT")
        #expect(child.fullName == "ava thompson")
    }

    @Test("Child.hasAllergies reflects the allergies list")
    func childHasAllergies() {
        #expect(TestSupport.child(allergies: ["Peanuts"]).hasAllergies)
        #expect(!TestSupport.child(allergies: []).hasAllergies)
    }

    @Test("Nap duration is nil unless both ends are set and ordered")
    func napDuration() {
        let entry = DiaryEntry(type: .nap, loggedByKeyworker: TestSupport.keyworker)
        #expect(entry.napDurationMinutes == nil)            // no times

        let start = TestSupport.day(0, hour: 12)
        entry.napStart = start
        entry.napEnd = TestSupport.calendar.date(byAdding: .minute, value: 75, to: start)
        #expect(entry.napDurationMinutes == 75)
    }

    @Test("Diary summary describes a meal with its amount")
    func mealSummary() {
        let entry = DiaryEntry(type: .meal, loggedByKeyworker: TestSupport.keyworker)
        entry.mealType = .lunch
        entry.mealAmount = .most
        #expect(entry.summary == "Lunch · Ate most")
    }

    @Test("WellbeingMood maps 1...5 to a title and emoji")
    func moodScale() {
        #expect(WellbeingMood(rawValue: 5) == .veryHappy)
        #expect(WellbeingMood.veryHappy.emoji == "😄")
        #expect(WellbeingMood.verySad.title == "Very low")
    }
}
