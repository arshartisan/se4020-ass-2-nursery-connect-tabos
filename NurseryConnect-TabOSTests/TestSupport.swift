//
//  TestSupport.swift
//  NurseryConnect-TabOSTests
//
//  Shared fixtures for the unit suite. Every test runs against an in-memory
//  ModelContainer (never touches disk) and uses a fixed UTC calendar + clock so
//  date-windowed aggregation is deterministic regardless of the machine's
//  timezone or the day the suite happens to run.
//

import Foundation
import SwiftData
@testable import NurseryConnect_TabOS

@MainActor
enum TestSupport {

    static let keyworker = "Sarah Mitchell"

    /// Containers are retained for the whole run so CoreData's background
    /// teardown of a finished test's store can't race a still-running test
    /// (the cause of the earlier SwiftData EXC_BREAKPOINT). Safe to hold —
    /// the suite is short-lived and these are in-memory only.
    private static var retainedContainers: [ModelContainer] = []

    /// A fresh, isolated in-memory context per call.
    static func makeContext() -> ModelContext {
        let container = ModelContainerProvider.makeInMemoryContainer()
        retainedContainers.append(container)
        return container.mainContext
    }

    /// Deterministic UTC calendar (no DST / locale drift in window maths).
    static var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }

    /// Fixed "now" the windowing tests anchor to.
    static var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 5, day: 30, hour: 12))!
    }

    /// `offset` whole days before `now` (at 09:00 UTC).
    static func day(_ offset: Int, hour: Int = 9) -> Date {
        let base = calendar.date(byAdding: .day, value: -offset, to: now)!
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: base)!
    }

    // MARK: - Model factories

    static func child(first: String = "Test",
                      last: String = "Child",
                      room: String = "Sunflower",
                      keyworker: String = keyworker,
                      allergies: [String] = [],
                      seed: Int = 0) -> Child {
        Child(firstName: first, lastName: last,
              dateOfBirth: Date(timeIntervalSince1970: 0),
              roomName: room, keyworkerName: keyworker,
              allergies: allergies, avatarSeed: seed)
    }

    @discardableResult
    static func wellbeing(_ mood: WellbeingMood, on date: Date,
                          child: Child, in context: ModelContext) -> DiaryEntry {
        let e = DiaryEntry(type: .wellbeing, timestamp: date,
                           loggedByKeyworker: keyworker, child: child)
        e.wellbeingMood = mood
        context.insert(e)
        return e
    }

    @discardableResult
    static func nap(minutes: Int, on date: Date,
                    child: Child, in context: ModelContext) -> DiaryEntry {
        let e = DiaryEntry(type: .nap, timestamp: date,
                           loggedByKeyworker: keyworker, child: child)
        e.napStart = date
        e.napEnd = calendar.date(byAdding: .minute, value: minutes, to: date)
        context.insert(e)
        return e
    }

    @discardableResult
    static func meal(_ amount: MealAmount, on date: Date,
                     child: Child, in context: ModelContext) -> DiaryEntry {
        let e = DiaryEntry(type: .meal, timestamp: date,
                           loggedByKeyworker: keyworker, child: child)
        e.mealType = .lunch
        e.mealAmount = amount
        context.insert(e)
        return e
    }
}
