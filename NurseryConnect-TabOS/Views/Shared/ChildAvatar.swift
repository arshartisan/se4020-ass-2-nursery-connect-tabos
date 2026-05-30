//
//  ChildAvatar.swift
//  NurseryConnect-TabOS
//
//  Initials-based avatar (no real child photos in this MVP — privacy by
//  design). A deterministic tint keeps each child visually distinct.
//

import SwiftUI

struct ChildAvatar: View {
    let initials: String
    var seed: Int = 0
    var size: CGFloat = 44

    private static let palette: [Color] = [
        AppColors.brand, AppColors.success, AppColors.warning,
        .purple, .teal, .pink, .indigo, .orange
    ]

    private var tint: Color {
        Self.palette[abs(seed) % Self.palette.count]
    }

    var body: some View {
        Circle()
            .fill(tint.opacity(0.18))
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
                    .foregroundStyle(tint)
            )
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
