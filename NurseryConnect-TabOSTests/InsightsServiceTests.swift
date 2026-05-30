//
//  InsightsServiceTests.swift
//  NurseryConnect-TabOSTests
//
//  Unit tests for the Swift Charts data layer — the aggregation that turns raw
//  diary entries into chartable series. Deterministic via a fixed UTC calendar
//  + clock (TestSupport).
//

import Testing
import Foundation
import SwiftData
@testable import NurseryConnect_TabOS

@Suite(.serialized)
@MainActor
struct InsightsServiceTests {

    private func makeService(_ context: ModelContext) -> InsightsService {
        InsightsService(context: context)
    }

    private func summary(_ service: InsightsService, child: Child?) throws -> InsightsSummary {
        try service.summary(for: child, scopeTitle: "Test",
                            calendar: TestSupport.calendar, now: TestSupport.now)
    }

    @Test("Mood series averages multiple same-day wellbeing entries into one point")
    func moodAveragesPerDay() throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child()
        ctx.insert(child)
        // Two entries on the same day: 4 and 2 → one point of value 3.
        TestSupport.wellbeing(.happy, on: TestSupport.day(0, hour: 9), child: child, in: ctx)
        TestSupport.wellbeing(.sad,   on: TestSupport.day(0, hour: 15), child: child, in: ctx)
        try ctx.save()

        let result = try summary(makeService(ctx), child: child)
        #expect(result.mood.count == 1)
        #expect(result.mood.first?.value == 3.0)
    }

    @Test("Mood series produces one point per distinct day, sorted ascending")
    func moodPerDaySorted() throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child()
        ctx.insert(child)
        TestSupport.wellbeing(.veryHappy, on: TestSupport.day(0), child: child, in: ctx) // 5
        TestSupport.wellbeing(.okay,      on: TestSupport.day(1), child: child, in: ctx) // 3
        try ctx.save()

        let result = try summary(makeService(ctx), child: child)
        #expect(result.mood.count == 2)
        #expect(result.mood.first!.date < result.mood.last!.date)   // ascending
        #expect(result.averageMood == 4.0)                          // (5 + 3) / 2
    }

    @Test("Nap series averages duration per day in minutes")
    func napDuration() throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child()
        ctx.insert(child)
        TestSupport.nap(minutes: 60, on: TestSupport.day(0, hour: 12), child: child, in: ctx)
        TestSupport.nap(minutes: 90, on: TestSupport.day(1, hour: 12), child: child, in: ctx)
        try ctx.save()

        let result = try summary(makeService(ctx), child: child)
        #expect(result.nap.count == 2)
        #expect(result.averageNapMinutes == 75.0)                   // (60 + 90) / 2
    }

    @Test("Meal series counts every amount level, including zeroes")
    func mealCounts() throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child()
        ctx.insert(child)
        TestSupport.meal(.all,  on: TestSupport.day(0), child: child, in: ctx)
        TestSupport.meal(.all,  on: TestSupport.day(1), child: child, in: ctx)
        TestSupport.meal(.some, on: TestSupport.day(2), child: child, in: ctx)
        try ctx.save()

        let result = try summary(makeService(ctx), child: child)
        // Every MealAmount case present so the bar-chart axis is stable.
        #expect(result.meals.count == MealAmount.allCases.count)
        #expect(result.meals.first { $0.amount == .all }?.count == 2)
        #expect(result.meals.first { $0.amount == .some }?.count == 1)
        #expect(result.meals.first { $0.amount == .none }?.count == 0)
    }

    @Test("Roster-wide scope aggregates across all children")
    func rosterWideAcrossChildren() throws {
        let ctx = TestSupport.makeContext()
        let a = TestSupport.child(first: "Ava", seed: 0)
        let b = TestSupport.child(first: "Noah", seed: 1)
        ctx.insert(a); ctx.insert(b)
        TestSupport.wellbeing(.happy, on: TestSupport.day(0), child: a, in: ctx)
        TestSupport.wellbeing(.okay,  on: TestSupport.day(0), child: b, in: ctx)
        try ctx.save()

        // child: nil = roster-wide.
        let result = try summary(makeService(ctx), child: nil)
        #expect(result.totalEntries == 2)
        // Both same-day → averaged into a single point ((4 + 3)/2 = 3.5).
        #expect(result.mood.count == 1)
        #expect(result.mood.first?.value == 3.5)
    }

    @Test("Window anchors to the latest entry, so an aged store still renders")
    func windowAnchorsToLatestEntry() throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child()
        ctx.insert(child)
        // All entries 30 days before `now`: a strictly now-anchored 7-day
        // window would exclude them. Anchoring to the latest entry includes them.
        TestSupport.wellbeing(.happy, on: TestSupport.day(30), child: child, in: ctx)
        TestSupport.wellbeing(.okay,  on: TestSupport.day(31), child: child, in: ctx)
        try ctx.save()

        let result = try summary(makeService(ctx), child: child)
        #expect(result.hasAnyData)
        #expect(result.totalEntries == 2)
    }

    @Test("Empty scope reports no data and nil averages")
    func emptyScope() throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child()
        ctx.insert(child)
        try ctx.save()

        let result = try summary(makeService(ctx), child: child)
        #expect(!result.hasAnyData)
        #expect(result.averageMood == nil)
        #expect(result.averageNapMinutes == nil)
    }
}
