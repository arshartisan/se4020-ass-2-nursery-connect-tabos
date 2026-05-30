//
//  QuickActionsBar.swift
//  NurseryConnect-TabOS
//
//  Five diary quick-log buttons + a prominent red "Report Incident" button.
//  One incident is always about a specific child, so it lives here on the
//  child screen (A1 design). Callbacks let the parent own presentation.
//

import SwiftUI

struct QuickActionsBar: View {
    var onLog: (DiaryEntryType) -> Void
    var onReportIncident: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Quick log")
                .sectionHeaderStyle()

            actionRow

            Button(role: .destructive) {
                onReportIncident()
            } label: {
                Label("Report Incident", systemImage: AppIcons.reportIncident)
            }
            .buttonStyle(PrimaryButtonStyle(tint: AppColors.danger))
            .accessibilityIdentifier("quickAction.reportIncident")
        }
    }

    private var actionRow: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(DiaryEntryType.allCases) { type in
                Button {
                    onLog(type)
                } label: {
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: type.icon)
                            .font(.title3)
                        Text(type.title)
                            .font(AppTypography.footnote)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    // Flex to equal width so all five share the column and fit
                    // any split-view size (portrait included) — no overflow.
                    .frame(maxWidth: .infinity, minHeight: AppSpacing.minTapTarget + 16)
                    .padding(.horizontal, AppSpacing.xs)
                    .background(AppColors.brandSoft)
                    .foregroundStyle(AppColors.brand)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.chipRadius, style: .continuous))
                }
                .accessibilityIdentifier("quickAction.\(type.rawValue)")
            }
        }
    }
}
