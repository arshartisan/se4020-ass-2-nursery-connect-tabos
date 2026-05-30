//
//  EmptyStateView.swift
//  NurseryConnect-TabOS
//
//  First-class empty state (criterion 7) — the user never sees a dead blank
//  canvas. Reused across every primary screen.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    var message: String? = nil
    var tint: Color = AppColors.brand

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundStyle(tint.opacity(0.7))
                .symbolRenderingMode(.hierarchical)
            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

#Preview {
    EmptyStateView(icon: "tray.fill",
                   title: "No children yet",
                   message: "Seeded children will appear here.")
}
