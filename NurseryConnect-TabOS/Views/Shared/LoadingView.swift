//
//  LoadingView.swift
//  NurseryConnect-TabOS
//
//  First-class loading state (criterion 7).
//

import SwiftUI

struct LoadingView: View {
    var label: String = "Loading…"

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .controlSize(.large)
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}
