//
//  InsightsDashboardView.swift
//  NurseryConnect-TabOS
//
//  The NEW feature (criterion 4 — advanced library: Swift Charts). Turns the
//  keyworker's existing diary logs into development & wellbeing trends:
//    • Wellbeing mood over time      → LineMark + PointMark (1–5 Leuven scale)
//    • Nap duration per day          → BarMark (minutes)
//    • Meal-portion distribution     → BarMark coloured by amount eaten
//  Each chart degrades to a first-class empty state when that signal has no
//  data in the window.
//

import SwiftUI
import Charts

struct InsightsDashboardView: View {
    let summary: InsightsSummary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                headerStats

                if summary.hasAnyData {
                    moodCard
                    napCard
                    mealCard
                } else {
                    EmptyStateView(icon: AppIcons.insights,
                                   title: "No data yet",
                                   message: "Log some diary entries for \(summary.scopeTitle) and the trends will appear here.")
                        .frame(minHeight: 280)
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .navigationTitle("Insights")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerStats: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(summary.scopeTitle).font(AppTypography.largeTitle)
            Text("Last \(summary.dayWindow) days · \(summary.totalEntries) entr\(summary.totalEntries == 1 ? "y" : "ies")")
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.textSecondary)

            HStack(spacing: AppSpacing.sm) {
                statTile(title: "Avg mood",
                         value: moodSummaryText,
                         icon: AppIcons.wellbeing,
                         tint: AppColors.brand)
                statTile(title: "Avg nap",
                         value: napSummaryText,
                         icon: AppIcons.nap,
                         tint: AppColors.success)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func statTile(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Label(title, systemImage: icon)
                .font(AppTypography.footnote.weight(.semibold))
                .foregroundStyle(tint)
            Text(value).font(AppTypography.title)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.sm)
        .background(tint.opacity(0.10),
                    in: RoundedRectangle(cornerRadius: AppSpacing.chipRadius, style: .continuous))
    }

    private var moodSummaryText: String {
        guard let avg = summary.averageMood else { return "—" }
        let mood = WellbeingMood(rawValue: Int(avg.rounded())) ?? .okay
        return "\(mood.emoji) \(String(format: "%.1f", avg))"
    }

    private var napSummaryText: String {
        guard let avg = summary.averageNapMinutes else { return "—" }
        return "\(Int(avg.rounded())) min"
    }

    // MARK: - Mood line chart

    private var moodCard: some View {
        chartCard(title: "Wellbeing mood", systemImage: AppIcons.wellbeing) {
            if summary.mood.isEmpty {
                miniEmpty("No wellbeing logged in this window.")
            } else {
                Chart(summary.mood) { point in
                    LineMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Mood", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppColors.brand)
                    .accessibilityHidden(true)

                    PointMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Mood", point.value)
                    )
                    .foregroundStyle(AppColors.brand)
                    .accessibilityLabel(weekday(point.date))
                    .accessibilityValue("Average mood \(String(format: "%.1f", point.value)) out of 5")
                }
                .chartYScale(domain: 1...5)
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let raw = value.as(Int.self),
                               let mood = WellbeingMood(rawValue: raw) {
                                Text(mood.emoji)
                            }
                        }
                    }
                }
                .chartXAxis { dayAxis }
                .frame(height: 200)
            }
        }
    }

    // MARK: - Nap bar chart

    private var napCard: some View {
        chartCard(title: "Nap duration", systemImage: AppIcons.nap) {
            if summary.nap.isEmpty {
                miniEmpty("No naps logged in this window.")
            } else {
                Chart(summary.nap) { point in
                    BarMark(
                        x: .value("Day", point.date, unit: .day),
                        y: .value("Minutes", point.minutes)
                    )
                    .foregroundStyle(AppColors.success.gradient)
                    .cornerRadius(4)
                    .accessibilityLabel(weekday(point.date))
                    .accessibilityValue("\(Int(point.minutes.rounded())) minutes")
                }
                .chartXAxis { dayAxis }
                .frame(height: 200)
            }
        }
    }

    // MARK: - Meal portions bar chart

    private var mealCard: some View {
        chartCard(title: "Meal portions eaten", systemImage: AppIcons.meal) {
            if summary.meals.allSatisfy({ $0.count == 0 }) {
                miniEmpty("No meals logged in this window.")
            } else {
                Chart(summary.meals) { bar in
                    BarMark(
                        x: .value("Amount", bar.amount.title),
                        y: .value("Count", bar.count)
                    )
                    .foregroundStyle(by: .value("Amount", bar.amount.title))
                    .cornerRadius(4)
                    .accessibilityLabel(bar.amount.title)
                    .accessibilityValue("\(bar.count) meal\(bar.count == 1 ? "" : "s")")
                }
                .chartForegroundStyleScale(range: mealColors)
                .chartLegend(.hidden)
                .frame(height: 200)
            }
        }
    }

    private var mealColors: [Color] {
        // none → warning, some → amber-ish, most/all → success (more = better).
        [AppColors.danger, AppColors.warning, AppColors.brand, AppColors.success]
    }

    // MARK: - Shared chart chrome

    private func chartCard<Content: View>(title: String,
                                          systemImage: String,
                                          @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Label(title, systemImage: systemImage).sectionHeaderStyle()
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var dayAxis: some AxisContent {
        AxisMarks(values: .stride(by: .day)) { _ in
            AxisGridLine()
            AxisTick()
            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
        }
    }

    /// Full weekday name for VoiceOver chart-mark labels.
    private func weekday(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide))
    }

    private func miniEmpty(_ message: String) -> some View {
        Text(message)
            .font(AppTypography.footnote)
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity, minHeight: 80)
    }
}
