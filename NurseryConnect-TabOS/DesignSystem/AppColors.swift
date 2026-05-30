//
//  AppColors.swift
//  NurseryConnect-TabOS
//
//  Design-system colour tokens — carried forward from Assignment 1.
//  Brief: "calm, professional childcare". Soft blue + warm off-white,
//  never stock iOS blue. Red is reserved exclusively for incident /
//  allergy affordances so the visual language reinforces severity.
//
//  Every token is backed by a Color Set in Assets.xcassets with explicit
//  light + dark variants, so the whole app is Dark-Mode ready for free
//  (criterion 7) and the palette can be re-skinned without touching code.
//

import SwiftUI

enum AppColors {

    // MARK: - Brand
    /// Primary brand blue — primary actions, selection, accents.
    static let brand = Color("BrandBlue")
    /// Soft brand tint — background of selected / highlighted rows.
    static let brandSoft = Color("BrandSoft")

    // MARK: - Surfaces
    /// Warm off-white app background (never pure white).
    static let background = Color("AppBackground")
    /// Pure-white card / surface colour.
    static let surface = Color("AppSurface")
    /// Subtle hairline / divider colour.
    static let separator = Color("AppSeparator")

    // MARK: - Text
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")

    // MARK: - Semantic
    /// Muted danger red — incidents, allergies, destructive affordances.
    static let danger = Color("DangerRed")
    /// Success green — successful saves / dispatched status.
    static let success = Color("SuccessGreen")
    /// Warning amber — dietary notes, pending status.
    static let warning = Color("WarningAmber")
}
