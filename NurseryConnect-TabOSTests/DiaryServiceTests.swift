//
//  DiaryServiceTests.swift
//  NurseryConnect-TabOSTests
//
//  Validation + persistence behaviour of the diary layer.
//

import Testing
import Foundation
import SwiftData
@testable import NurseryConnect_TabOS

@Suite(.serialized)
@MainActor
struct DiaryServiceTests {

    @Test("Saving a wellbeing entry with no mood throws")
    func wellbeingRequiresMood() async throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child(); ctx.insert(child)
        let service = DiaryService(context: ctx)

        let entry = DiaryEntry(type: .wellbeing, loggedByKeyworker: TestSupport.keyworker, child: child)
        await #expect(throws: DiaryServiceError.self) {
            try await service.save(entry)
        }
    }

    @Test("Saving a meal with no meal type throws")
    func mealRequiresType() async throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child(); ctx.insert(child)
        let service = DiaryService(context: ctx)

        let entry = DiaryEntry(type: .meal, loggedByKeyworker: TestSupport.keyworker, child: child)
        await #expect(throws: DiaryServiceError.self) {
            try await service.save(entry)
        }
    }

    @Test("A valid activity entry saves and is fetched back")
    func savesAndFetches() async throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child(); ctx.insert(child)
        let service = DiaryService(context: ctx)

        let entry = DiaryEntry(type: .activity, loggedByKeyworker: TestSupport.keyworker,
                               notes: "Built a tall tower", child: child)
        entry.activityName = "Block play"
        try await service.save(entry)

        let fetched = try service.entries(for: child)
        #expect(fetched.count == 1)
        #expect(fetched.first?.activityName == "Block play")
    }

    @Test("entries(for:) returns newest first")
    func entriesSortedNewestFirst() async throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child(); ctx.insert(child)
        let service = DiaryService(context: ctx)

        let older = DiaryEntry(type: .activity, timestamp: TestSupport.day(2),
                               loggedByKeyworker: TestSupport.keyworker, child: child)
        older.activityName = "Older"
        let newer = DiaryEntry(type: .activity, timestamp: TestSupport.day(0),
                               loggedByKeyworker: TestSupport.keyworker, child: child)
        newer.activityName = "Newer"
        try await service.save(older)
        try await service.save(newer)

        let fetched = try service.entries(for: child)
        #expect(fetched.first?.activityName == "Newer")
        #expect(fetched.last?.activityName == "Older")
    }
}
