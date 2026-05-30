//
//  BodyMapView.swift
//  NurseryConnect-TabOS
//
//  Tappable body-map region selector for injury locations (Children Act 1989
//  physical-evidence record). A stylised figure anchors the selection; the
//  region chips are the accessible, multi-select control.
//

import SwiftUI

struct BodyMapView: View {
    let selected: Set<BodyMapRegion>
    var onToggle: (BodyMapRegion) -> Void

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: AppSpacing.sm)]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "figure.stand")
                    .font(.system(size: 64))
                    .foregroundStyle(AppColors.brand.opacity(0.5))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Tap each affected area")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    if selected.isEmpty {
                        Text("No areas marked")
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                    } else {
                        Text(selected.map(\.title).sorted().joined(separator: ", "))
                            .font(AppTypography.footnote.weight(.semibold))
                            .foregroundStyle(AppColors.danger)
                    }
                }
                Spacer()
            }

            LazyVGrid(columns: columns, spacing: AppSpacing.sm) {
                ForEach(BodyMapRegion.allCases) { region in
                    let isOn = selected.contains(region)
                    Button {
                        onToggle(region)
                    } label: {
                        Text(region.title)
                            .font(AppTypography.footnote.weight(isOn ? .semibold : .regular))
                            .frame(maxWidth: .infinity, minHeight: AppSpacing.minTapTarget)
                            .background(isOn ? AppColors.danger.opacity(0.16) : AppColors.brandSoft)
                            .foregroundStyle(isOn ? AppColors.danger : AppColors.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.chipRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppSpacing.chipRadius, style: .continuous)
                                    .stroke(isOn ? AppColors.danger : .clear, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isOn ? [.isSelected] : [])
                }
            }
        }
    }
}
