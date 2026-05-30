//
//  AppSpacing.swift
//  NurseryConnect-TabOS
//
//  Centralised spacing scale (carried forward from Assignment 1) so
//  whitespace rhythm stays consistent across every screen.
//

import CoreGraphics

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    /// Corner radius used by cards / surfaces.
    static let cornerRadius: CGFloat = 16
    /// Smaller corner radius for chips / inline pills.
    static let chipRadius: CGFloat = 10

    /// Apple HIG minimum tap target.
    static let minTapTarget: CGFloat = 44
}
