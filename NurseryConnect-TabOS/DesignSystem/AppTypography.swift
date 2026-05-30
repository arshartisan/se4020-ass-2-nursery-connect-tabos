//
//  AppTypography.swift
//  NurseryConnect-TabOS
//
//  Typography tokens (carried forward from Assignment 1). Title levels use
//  the `.rounded` system design — softer and more approachable than default
//  San Francisco — while every token keeps its Dynamic Type text style, so
//  larger accessibility text sizes are fully supported (criterion 7).
//

import SwiftUI

enum AppTypography {
    /// Large screen title (rounded).
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    /// Section / card title (rounded).
    static let title = Font.system(.title2, design: .rounded).weight(.semibold)
    /// Sub-title / prominent label (rounded).
    static let headline = Font.system(.headline, design: .rounded)
    /// Standard body copy.
    static let body = Font.system(.body)
    /// Secondary / caption copy.
    static let caption = Font.system(.subheadline)
    /// Small metadata (timestamps, badges).
    static let footnote = Font.system(.footnote)
}

extension View {
    /// Convenience for applying a typography token + primary text colour.
    func appFont(_ font: Font, color: Color = AppColors.textPrimary) -> some View {
        self.font(font).foregroundStyle(color)
    }
}
