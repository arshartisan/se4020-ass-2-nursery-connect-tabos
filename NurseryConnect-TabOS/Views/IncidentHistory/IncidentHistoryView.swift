//
//  IncidentHistoryView.swift
//  NurseryConnect-TabOS
//
//  Cross-child incident history (the Incidents section content column).
//  Surfacing incidents at the top level means an inspector/manager can audit
//  the full trail without first drilling into a child (A1 design).
//

import SwiftUI

struct IncidentHistoryView: View {
    @Bindable var viewModel: IncidentHistoryViewModel

    var body: some View {
        Group {
            if viewModel.allReports.isEmpty {
                EmptyStateView(icon: AppIcons.incidents,
                               title: "No incidents recorded",
                               message: "Reports filed from a child’s day view appear here.")
            } else {
                List(selection: $viewModel.selectedID) {
                    Section {
                        ForEach(viewModel.filtered) { report in
                            IncidentRow(report: report)
                                .tag(report.id)
                        }
                    } header: {
                        Text("\(viewModel.filtered.count) report\(viewModel.filtered.count == 1 ? "" : "s")")
                    }
                }
                .listStyle(.inset)
            }
        }
        .navigationTitle("Incidents")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Filter", selection: $viewModel.filter) {
                    ForEach(IncidentHistoryViewModel.Filter.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
            }
        }
        .task { viewModel.load() }
    }
}

private struct IncidentRow: View {
    let report: IncidentReport

    private var severityColor: Color {
        switch report.severity {
        case .low:    return AppColors.success
        case .medium: return AppColors.warning
        case .high:   return AppColors.danger
        }
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: 3)
                .fill(severityColor)
                .frame(width: 5)
                .frame(maxHeight: .infinity)

            Image(systemName: report.category.icon)
                .foregroundStyle(AppColors.danger)
                .frame(width: 32, height: 32)
                .background(AppColors.danger.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(report.child?.fullName ?? "Unknown child")
                    .font(AppTypography.headline)
                Text("\(report.category.title) · \(report.severity.title)")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                Text(report.submittedAt, format: .dateTime.day().month().hour().minute())
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            DispatchBadge(status: report.dispatchStatus)
        }
        .padding(.vertical, AppSpacing.xs)
        .frame(minHeight: 56)
        .accessibilityElement(children: .combine)
    }
}

struct DispatchBadge: View {
    let status: DispatchStatus

    var body: some View {
        Text(status.title)
            .font(AppTypography.footnote.weight(.semibold))
            .foregroundStyle(status == .dispatched ? AppColors.success : AppColors.warning)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 2)
            .background((status == .dispatched ? AppColors.success : AppColors.warning).opacity(0.15),
                        in: Capsule())
    }
}
