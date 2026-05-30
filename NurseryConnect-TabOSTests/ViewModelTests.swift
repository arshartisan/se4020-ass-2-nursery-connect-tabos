//
//  ViewModelTests.swift
//  NurseryConnect-TabOSTests
//
//  ViewModel-level behaviour: roster loading + GDPR keyworker filtering, roster
//  search, and Insights scope selection driving the summary.
//

import Testing
import Foundation
import SwiftData
@testable import NurseryConnect_TabOS

@Suite(.serialized)
@MainActor
struct ChildRosterServiceTests {

    @Test("Roster fetch only returns the keyworker's own children (data minimisation)")
    func filtersByKeyworker() throws {
        let ctx = TestSupport.makeContext()
        ctx.insert(TestSupport.child(first: "Mine", keyworker: "Sarah Mitchell"))
        ctx.insert(TestSupport.child(first: "Theirs", keyworker: "Other Keyworker"))
        try ctx.save()

        let service = ChildRosterService(context: ctx)
        let mine = try service.fetchAssignedChildren(for: "Sarah Mitchell")
        #expect(mine.count == 1)
        #expect(mine.first?.firstName == "Mine")
    }
}

@Suite(.serialized)
@MainActor
struct ChildRosterViewModelTests {

    @Test("load() moves to .loaded and populates children")
    func loadPopulates() throws {
        let ctx = TestSupport.makeContext()
        ctx.insert(TestSupport.child(first: "Ava"))
        ctx.insert(TestSupport.child(first: "Noah"))
        try ctx.save()

        let vm = ChildRosterViewModel(service: ChildRosterService(context: ctx),
                                      keyworker: TestSupport.keyworker)
        vm.load()
        #expect(vm.state == .loaded)
        #expect(vm.children.count == 2)
    }

    @Test("searchText filters by name, case-insensitively")
    func searchFilters() throws {
        let ctx = TestSupport.makeContext()
        ctx.insert(TestSupport.child(first: "Ava", last: "Thompson"))
        ctx.insert(TestSupport.child(first: "Noah", last: "Patel"))
        try ctx.save()

        let vm = ChildRosterViewModel(service: ChildRosterService(context: ctx),
                                      keyworker: TestSupport.keyworker)
        vm.load()
        vm.searchText = "ava"
        #expect(vm.filteredChildren.count == 1)
        #expect(vm.filteredChildren.first?.firstName == "Ava")

        vm.searchText = ""
        #expect(vm.filteredChildren.count == 2)   // empty query → all
    }
}

@Suite(.serialized)
@MainActor
struct InsightsViewModelTests {

    private func makeVM(_ ctx: ModelContext) -> InsightsViewModel {
        InsightsViewModel(rosterService: ChildRosterService(context: ctx),
                          insightsService: InsightsService(context: ctx),
                          keyworker: TestSupport.keyworker)
    }

    @Test("load() produces a roster-wide summary by default")
    func defaultRosterSummary() throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child(first: "Ava"); ctx.insert(child)
        TestSupport.wellbeing(.happy, on: TestSupport.day(0), child: child, in: ctx)
        try ctx.save()

        let vm = makeVM(ctx)
        vm.load()
        #expect(vm.state == .loaded)
        #expect(vm.selectedScope == .roster)
        #expect(vm.summary?.hasAnyData == true)
    }

    @Test("Selecting a child scope recomputes the summary for that child")
    func childScopeSummary() throws {
        let ctx = TestSupport.makeContext()
        let ava = TestSupport.child(first: "Ava"); ctx.insert(ava)
        let noah = TestSupport.child(first: "Noah"); ctx.insert(noah)
        TestSupport.wellbeing(.happy, on: TestSupport.day(0), child: ava, in: ctx)
        // Noah has no entries.
        try ctx.save()

        let vm = makeVM(ctx)
        vm.load()
        vm.selectedScope = .child(noah.id)
        #expect(vm.summary?.scopeTitle == "Noah Child")
        #expect(vm.summary?.hasAnyData == false)

        vm.selectedScope = .child(ava.id)
        #expect(vm.summary?.hasAnyData == true)
    }
}
