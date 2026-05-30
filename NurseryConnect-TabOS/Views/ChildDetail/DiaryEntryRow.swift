//
//  DiaryEntryRow.swift
//  NurseryConnect-TabOS
//
//  One row in the per-child diary timeline.
//

import SwiftUI

struct DiaryEntryRow: View {
    let entry: DiaryEntry

    private var tint: Color {
        switch entry.type {
        case .wellbeing: return AppColors.danger
        case .nap:       return .indigo
        case .meal:      return AppColors.warning
        case .activity:  return AppColors.brand
        case .nappy:     return .teal
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: entry.type.icon)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(entry.summary)
                        .font(AppTypography.headline)
                    if entry.type == .wellbeing, let mood = entry.wellbeingMood {
                        Text(mood.emoji)
                    }
                    Spacer()
                    Text(entry.timestamp, format: .dateTime.hour().minute())
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
                Text("\(entry.type.title) · \(entry.loggedByKeyworker)")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .accessibilityElement(children: .combine)
    }
}
