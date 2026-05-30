//
//  IncidentFormViewModel.swift
//  NurseryConnect-TabOS
//
//  @Observable @MainActor state machine driving the incident submission flow.
//  Explicit SubmissionState; async submit wraps the thrown service error into
//  a displayable message; success/failure each drive a distinct haptic.
//  (Carried forward from A1.)
//

import Foundation
import Observation

enum SubmissionState: Equatable {
    case idle
    case submitting
    case success
    case failed(String)
}

@Observable
@MainActor
final class IncidentFormViewModel {

    // Form state
    var category: IncidentCategory = .minorAccident
    var severity: IncidentSeverity = .low
    var occurredAt: Date = .now           // read-only in the UI (no backdating)
    var location: String = ""
    var descriptionText: String = ""
    var immediateActionTaken: String = ""
    var witnesses: String = ""
    var bodyMapRegions: Set<BodyMapRegion> = []
    /// PencilKit signature PNG — the keyworker's sign-off (required to submit).
    var signatureData: Data?

    // Submission state
    var submissionState: SubmissionState = .idle
    var errorMessage: String?
    var isSubmitting: Bool { submissionState == .submitting }

    let child: Child
    private let incidentService: IncidentService

    init(child: Child, incidentService: IncidentService) {
        self.child = child
        self.incidentService = incidentService
    }

    var isValid: Bool {
        !descriptionText.trimmed.isEmpty
            && !immediateActionTaken.trimmed.isEmpty
            && signatureData != nil
    }

    func toggleRegion(_ region: BodyMapRegion) {
        if bodyMapRegions.contains(region) {
            bodyMapRegions.remove(region)
        } else {
            bodyMapRegions.insert(region)
        }
    }

    func submit() async -> Bool {
        submissionState = .submitting
        errorMessage = nil

        let report = IncidentReport(
            child: child,
            category: category,
            severity: severity,
            occurredAt: occurredAt,
            location: location.trimmed,
            descriptionText: descriptionText.trimmed,
            immediateActionTaken: immediateActionTaken.trimmed,
            witnesses: witnesses.trimmed,
            bodyMapRegions: Array(bodyMapRegions),
            loggedByKeyworker: SeedDataService.currentKeyworker,
            signatureImageData: signatureData
        )

        do {
            try await incidentService.submit(report)
            Haptics.success()
            submissionState = .success
            return true
        } catch {
            Haptics.error()
            errorMessage = error.localizedDescription
            submissionState = .failed(error.localizedDescription)
            return false
        }
    }
}
