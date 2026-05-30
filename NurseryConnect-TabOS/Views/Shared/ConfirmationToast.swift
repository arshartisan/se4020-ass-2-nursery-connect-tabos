//
//  ConfirmationToast.swift
//  NurseryConnect-TabOS
//
//  Slide-in success toast (multi-channel feedback, never colour-only).
//  Carried forward from A1; presented via the `.confirmationToast` modifier.
//

import SwiftUI

struct ConfirmationToast: View {
    let message: String
    var systemImage: String = AppIcons.success

    var body: some View {
        Label(message, systemImage: systemImage)
            .font(AppTypography.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColors.success, in: Capsule())
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            .accessibilityElement(children: .combine)
    }
}

private struct ConfirmationToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if isPresented {
                ConfirmationToast(message: message)
                    .padding(.top, AppSpacing.md)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        // Auto-dismiss after a short beat.
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            withAnimation(.spring) { isPresented = false }
                        }
                    }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
    }
}

extension View {
    /// Shows a slide-in success toast while `isPresented` is true.
    func confirmationToast(isPresented: Binding<Bool>, message: String) -> some View {
        modifier(ConfirmationToastModifier(isPresented: isPresented, message: message))
    }
}
