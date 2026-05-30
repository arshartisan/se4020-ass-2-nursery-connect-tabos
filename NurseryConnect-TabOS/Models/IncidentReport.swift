//
//  IncidentReport.swift
//  NurseryConnect-TabOS
//
//  Carried forward from Assignment 1.
//
//  Incident records are IMMUTABLE post-submission to satisfy the Children Act
//  1989 safeguarding audit trail. The UI never offers an edit path; the
//  `occurredAt` timestamp is system-stamped and read-only (GDPR Art. 5(1)(d)
//  accuracy — no manual backdating).
//

import Foundation
import SwiftData

@Model
final class IncidentReport {
    var id: UUID
    var categoryRaw: String
    var severityRaw: String
    /// System-clock time the incident occurred (read-only in the form).
    var occurredAt: Date
    var location: String
    var descriptionText: String
    var immediateActionTaken: String
    var witnesses: String
    /// Body-map injury regions (Codable value type stored by SwiftData).
    var bodyMapRegions: [BodyMapRegion]
    var loggedByKeyworker: String
    /// Stamped by the system at submission — the immutability anchor.
    var submittedAt: Date
    var dispatchStatusRaw: String

    var child: Child?

    init(
        id: UUID = UUID(),
        child: Child? = nil,
        category: IncidentCategory,
        severity: IncidentSeverity,
        occurredAt: Date = .now,
        location: String = "",
        descriptionText: String = "",
        immediateActionTaken: String = "",
        witnesses: String = "",
        bodyMapRegions: [BodyMapRegion] = [],
        loggedByKeyworker: String,
        submittedAt: Date = .now,
        dispatchStatus: DispatchStatus = .pending
    ) {
        self.id = id
        self.child = child
        self.categoryRaw = category.rawValue
        self.severityRaw = severity.rawValue
        self.occurredAt = occurredAt
        self.location = location
        self.descriptionText = descriptionText
        self.immediateActionTaken = immediateActionTaken
        self.witnesses = witnesses
        self.bodyMapRegions = bodyMapRegions
        self.loggedByKeyworker = loggedByKeyworker
        self.submittedAt = submittedAt
        self.dispatchStatusRaw = dispatchStatus.rawValue
    }
}

// MARK: - Typed accessors

extension IncidentReport {
    var category: IncidentCategory {
        get { IncidentCategory(rawValue: categoryRaw) ?? .minorAccident }
        set { categoryRaw = newValue.rawValue }
    }
    var severity: IncidentSeverity {
        get { IncidentSeverity(rawValue: severityRaw) ?? .low }
        set { severityRaw = newValue.rawValue }
    }
    var dispatchStatus: DispatchStatus {
        get { DispatchStatus(rawValue: dispatchStatusRaw) ?? .pending }
        set { dispatchStatusRaw = newValue.rawValue }
    }
}

// MARK: - Enums

enum IncidentCategory: String, CaseIterable, Identifiable, Codable {
    case minorAccident, nearMiss, injury, illness, behavioural, safeguardingConcern
    var id: String { rawValue }

    var title: String {
        switch self {
        case .minorAccident:       return "Minor accident"
        case .nearMiss:            return "Near miss"
        case .injury:              return "Injury"
        case .illness:             return "Illness"
        case .behavioural:         return "Behavioural"
        case .safeguardingConcern: return "Safeguarding"
        }
    }

    var icon: String {
        switch self {
        case .minorAccident:       return "bandage.fill"
        case .nearMiss:            return "exclamationmark.triangle"
        case .injury:              return "cross.case.fill"
        case .illness:             return "thermometer.medium"
        case .behavioural:         return "person.fill.questionmark"
        case .safeguardingConcern: return "shield.lefthalf.filled"
        }
    }
}

enum IncidentSeverity: String, CaseIterable, Identifiable, Codable {
    case low, medium, high
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum DispatchStatus: String, CaseIterable, Identifiable, Codable {
    case pending, dispatched
    var id: String { rawValue }
    var title: String {
        switch self {
        case .pending:    return "Pending"
        case .dispatched: return "Sent to manager"
        }
    }
}

/// Body-map regions a keyworker can tag for an injury.
enum BodyMapRegion: String, CaseIterable, Identifiable, Codable {
    case head, face, neck
    case leftArm, rightArm, leftHand, rightHand
    case chest, back
    case leftLeg, rightLeg, leftFoot, rightFoot

    var id: String { rawValue }

    var title: String {
        switch self {
        case .head: return "Head"
        case .face: return "Face"
        case .neck: return "Neck"
        case .leftArm: return "Left arm"
        case .rightArm: return "Right arm"
        case .leftHand: return "Left hand"
        case .rightHand: return "Right hand"
        case .chest: return "Chest"
        case .back: return "Back"
        case .leftLeg: return "Left leg"
        case .rightLeg: return "Right leg"
        case .leftFoot: return "Left foot"
        case .rightFoot: return "Right foot"
        }
    }
}
