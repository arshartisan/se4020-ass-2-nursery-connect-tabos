//
//  IncidentFormView.swift
//  NurseryConnect-TabOS
//
//  Full-screen incident form — incidents are weighty records and deserve the
//  screen real estate. Sections follow the RIDDOR-inspired field order:
//  category → severity → when/where → what happened → body map → action →
//  witnesses. The timestamp is read-only (no backdating). On success an
//  animated IncidentSubmittedView overlays and auto-dismisses.
//

import SwiftUI

struct IncidentFormView: View {
    @Bindable var viewModel: IncidentFormViewModel
    @Environment(\.dismiss) private var dismiss

    private let categoryColumns = [GridItem(.adaptive(minimum: 150), spacing: AppSpacing.sm)]

    var body: some View {
        NavigationStack {
            Form {
                categorySection
                severitySection
                whenWhereSection
                whatHappenedSection
                bodyMapSection
                actionSection
                witnessSection
            }
            .navigationTitle("Report Incident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(viewModel.isSubmitting)
                }
            }
            .safeAreaInset(edge: .bottom) { submitBar }
            .interactiveDismissDisabled(viewModel.isSubmitting)
            .errorAlert($viewModel.errorMessage)
            .overlay {
                if viewModel.submissionState == .success {
                    IncidentSubmittedView { dismiss() }
                }
            }
        }
    }

    // MARK: - Sections

    private var categorySection: some View {
        Section {
            LazyVGrid(columns: categoryColumns, spacing: AppSpacing.sm) {
                ForEach(IncidentCategory.allCases) { category in
                    let isOn = viewModel.category == category
                    Button {
                        viewModel.category = category
                    } label: {
                        Label(category.title, systemImage: category.icon)
                            .font(AppTypography.footnote.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: AppSpacing.minTapTarget + 8)
                            .background(isOn ? AppColors.brandSoft : AppColors.surface)
                            .foregroundStyle(isOn ? AppColors.brand : AppColors.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.chipRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.chipRadius, style: .continuous)
                                    .stroke(isOn ? AppColors.brand : AppColors.separator, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, AppSpacing.xs)
        } header: {
            Text("Category").sectionHeaderStyle()
        }
    }

    private var severitySection: some View {
        Section {
            Picker("Severity", selection: $viewModel.severity) {
                ForEach(IncidentSeverity.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            HStack(spacing: AppSpacing.sm) {
                Circle().fill(severityColor).frame(width: 12, height: 12)
                Text(severityHint)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }
        } header: {
            Text("Severity").sectionHeaderStyle()
        }
    }

    private var whenWhereSection: some View {
        Section {
            // Read-only timestamp — GDPR accuracy / no manual backdating.
            LabeledContent("Time") {
                Text(viewModel.occurredAt, format: .dateTime.day().month().hour().minute())
            }
            TextField("Location (e.g. Sunflower Room)", text: $viewModel.location)
        } header: {
            Text("When & where").sectionHeaderStyle()
        } footer: {
            Text("The time is taken from the system clock and cannot be edited.")
        }
    }

    private var whatHappenedSection: some View {
        Section {
            TextField("Describe what happened", text: $viewModel.descriptionText, axis: .vertical)
                .lineLimit(3...8)
                .accessibilityIdentifier("incidentForm.description")
        } header: {
            Text("What happened").sectionHeaderStyle()
        }
    }

    private var bodyMapSection: some View {
        Section {
            BodyMapView(selected: viewModel.bodyMapRegions) { viewModel.toggleRegion($0) }
        } header: {
            Text("Body map").sectionHeaderStyle()
        }
    }

    private var actionSection: some View {
        Section {
            TextField("Immediate action taken", text: $viewModel.immediateActionTaken, axis: .vertical)
                .lineLimit(2...6)
        } header: {
            Text("Action taken").sectionHeaderStyle()
        }
    }

    private var witnessSection: some View {
        Section {
            TextField("Witnesses (comma separated)", text: $viewModel.witnesses)
        } header: {
            Text("Witnesses").sectionHeaderStyle()
        }
    }

    // MARK: - Submit

    private var submitBar: some View {
        Button {
            Task { await viewModel.submit() }
        } label: {
            if viewModel.isSubmitting {
                ProgressView().tint(.white)
            } else {
                Text("Submit Incident")
            }
        }
        .buttonStyle(PrimaryButtonStyle(tint: AppColors.danger, isEnabled: viewModel.isValid))
        .disabled(!viewModel.isValid || viewModel.isSubmitting)
        .padding(AppSpacing.md)
        .background(.bar)
        .accessibilityIdentifier("incidentForm.submitButton")
    }

    private var severityColor: Color {
        switch viewModel.severity {
        case .low:    return AppColors.success
        case .medium: return AppColors.warning
        case .high:   return AppColors.danger
        }
    }

    private var severityHint: String {
        switch viewModel.severity {
        case .low:    return "Minor — comforted, no follow-up needed."
        case .medium: return "Notable — parent should be told at pickup."
        case .high:   return "Serious — same-day parent + manager notification."
        }
    }
}
