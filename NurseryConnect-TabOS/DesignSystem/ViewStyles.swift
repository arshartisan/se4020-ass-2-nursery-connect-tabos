//
//  ViewStyles.swift
//  NurseryConnect-TabOS
//
//  Reusable view modifiers + button styles (carried forward from
//  Assignment 1). A single change here re-skins the whole app:
//  CardStyle, PrimaryButtonStyle, SectionHeaderStyle.
//

import SwiftUI

// MARK: - CardStyle

/// Gives every card a shared rounded surface + soft shadow.
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.md)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

extension View {
    /// Apply the shared card surface (rounded shape + soft shadow).
    func cardStyle() -> some View { modifier(CardStyle()) }
}

// MARK: - PrimaryButtonStyle

/// Drives every primary action button — full width, brand fill, press scale.
struct PrimaryButtonStyle: ButtonStyle {
    var tint: Color = AppColors.brand
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTypography.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: AppSpacing.minTapTarget)
            .padding(.vertical, AppSpacing.xs)
            .background(isEnabled ? tint : tint.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.chipRadius, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - SectionHeaderStyle

/// Unifies form / list section headings.
struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppTypography.headline)
            .foregroundStyle(AppColors.textPrimary)
            .textCase(nil)
    }
}

extension View {
    func sectionHeaderStyle() -> some View { modifier(SectionHeaderStyle()) }
}

// MARK: - Chip

/// Small inline pill used for allergy / dietary / status badges.
struct Chip: View {
    let text: String
    var systemImage: String? = nil
    var tint: Color = AppColors.brand

    var body: some View {
        Label {
            Text(text)
        } icon: {
            if let systemImage { Image(systemName: systemImage) }
        }
        .labelStyle(.titleAndIcon)
        .font(AppTypography.footnote.weight(.semibold))
        .foregroundStyle(tint)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(tint.opacity(0.14))
        .clipShape(Capsule())
    }
}
