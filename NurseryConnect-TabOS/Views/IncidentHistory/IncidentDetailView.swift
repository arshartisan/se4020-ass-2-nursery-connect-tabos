//
//  IncidentDetailView.swift
//  NurseryConnect-TabOS
//
//  Read-only view of a submitted incident. Mirrors the form but every field
//  is non-editable: "Incident records are immutable post-submission to
//  satisfy the Children Act 1989 safeguarding audit trail."
//

import SwiftUI

struct IncidentDetailView: View {
    let incident: IncidentReport

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                header

                field("What happened", incident.descriptionText)
                field("Immediate action taken", incident.immediateActionTaken)

                if !incident.location.isEmpty {
                    field("Location", incident.location)
                }
                if !incident.witnesses.isEmpty {
                    field("Witnesses", incident.witnesses)
                }
                if !incident.bodyMapRegions.isEmpty {
                    field("Injury locations",
                          incident.bodyMapRegions.map(\.title).sorted().joined(separator: ", "))
                }

                metadata
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .navigationTitle("Incident")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: incident.category.icon)
                    .font(.title2)
                    .foregroundStyle(AppColors.danger)
                VStack(alignment: .leading, spacing: 2) {
                    Text(incident.child?.fullName ?? "Unknown child")
                        .font(AppTypography.title)
                    Text("\(incident.category.title) · \(incident.severity.title) severity")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                DispatchBadge(status: incident.dispatchStatus)
            }
            Label("This record is immutable (safeguarding audit trail).",
                  systemImage: "lock.fill")
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)
        }
        .cardStyle()
    }

    private func field(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title).sectionHeaderStyle()
            Text(value)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var metadata: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Record").sectionHeaderStyle()
            LabeledContent("Occurred") {
                Text(incident.occurredAt, format: .dateTime.day().month().year().hour().minute())
            }
            LabeledContent("Submitted") {
                Text(incident.submittedAt, format: .dateTime.day().month().year().hour().minute())
            }
            LabeledContent("Logged by", value: incident.loggedByKeyworker)
        }
        .font(AppTypography.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
