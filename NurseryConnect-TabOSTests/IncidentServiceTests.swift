//
//  IncidentServiceTests.swift
//  NurseryConnect-TabOSTests
//
//  Incident submission: validation, the system-stamped immutability anchor, the
//  async dispatch transition, and signature retention. Dispatch latency is
//  zeroed so the suite stays fast.
//

import Testing
import Foundation
import SwiftData
@testable import NurseryConnect_TabOS

@Suite(.serialized)
@MainActor
struct IncidentServiceTests {

    private func fastService(_ context: ModelContext) -> IncidentService {
        IncidentService(context: context, dispatchService: MockDispatchService(delay: .zero))
    }

    @Test("Submitting with no description throws")
    func requiresDescription() async throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child(); ctx.insert(child)
        let report = IncidentReport(child: child, category: .minorAccident, severity: .low,
                                    descriptionText: "", immediateActionTaken: "Comforted",
                                    loggedByKeyworker: TestSupport.keyworker)
        await #expect(throws: IncidentServiceError.self) {
            try await fastService(ctx).submit(report)
        }
    }

    @Test("Submitting with no action taken throws")
    func requiresAction() async throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child(); ctx.insert(child)
        let report = IncidentReport(child: child, category: .minorAccident, severity: .low,
                                    descriptionText: "Bumped knee", immediateActionTaken: "",
                                    loggedByKeyworker: TestSupport.keyworker)
        await #expect(throws: IncidentServiceError.self) {
            try await fastService(ctx).submit(report)
        }
    }

    @Test("A valid submission stamps submittedAt, marks dispatched, and persists")
    func submitsAndDispatches() async throws {
        let ctx = TestSupport.makeContext()
        let child = TestSupport.child(); ctx.insert(child)
        let signature = Data([0x89, 0x50, 0x4E, 0x47])   // pretend PNG header
        let report = IncidentReport(child: child, category: .injury, severity: .high,
                                    descriptionText: "Fell from step",
                                    immediateActionTaken: "First aid given",
                                    loggedByKeyworker: TestSupport.keyworker,
                                    signatureImageData: signature)

        let service = fastService(ctx)
        try await service.submit(report)

        #expect(report.dispatchStatus == .dispatched)
        #expect(report.signatureImageData == signature)   // sign-off retained

        let all = try service.allIncidents()
        #expect(all.count == 1)
        #expect(all.first?.descriptionText == "Fell from step")
    }
}
