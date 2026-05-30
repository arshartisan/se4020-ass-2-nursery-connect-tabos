//
//  IncidentDetailView.swift
//  NurseryConnect-TabOS
//
//  Read-only view of a submitted incident. Mirrors the form but every field
//  is non-editable: "Incident records are immutable post-submission to
//  satisfy the Children Act 1989 safeguarding audit trail."
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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

                signature

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

    @ViewBuilder
    private var signature: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Keyworker sign-off").sectionHeaderStyle()
            if let image = signatureImage {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 120, alignment: .leading)
                    .accessibilityLabel("Keyworker signature")
                Text("Signed by \(incident.loggedByKeyworker)")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                Text("No signature on file.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    /// Decode the stored PNG into a SwiftUI `Image` (UIKit-guarded so SourceKit's
    /// macOS index stays quiet; the iPad target always has UIKit).
    private var signatureImage: Image? {
        #if canImport(UIKit)
        guard let data = incident.signatureImageData,
              let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #else
        return nil
        #endif
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
