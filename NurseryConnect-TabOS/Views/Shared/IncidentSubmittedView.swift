//
//  IncidentSubmittedView.swift
//  NurseryConnect-TabOS
//
//  Animated success overlay shown after an incident is submitted. Bouncing
//  SF Symbol + spring scale/opacity. Auto-dismisses. (Carried forward from A1.)
//

import SwiftUI

struct IncidentSubmittedView: View {
    var onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                Image(systemName: AppIcons.success)
                    .font(.system(size: 64))
                    .foregroundStyle(AppColors.success)
                    .symbolEffect(.bounce, value: appeared)
                Text("Incident submitted")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                Text("Routed to the setting manager for review.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(AppSpacing.xl)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))
            .shadow(radius: 20)
            .scaleEffect(appeared ? 1 : 0.85)
            .opacity(appeared ? 1 : 0)
            .padding(AppSpacing.xl)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { appeared = true }
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                onDismiss()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Incident submitted and routed to the setting manager.")
    }
}
