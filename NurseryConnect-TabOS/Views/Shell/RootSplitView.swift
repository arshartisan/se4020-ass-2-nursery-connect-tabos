//
//  RootSplitView.swift
//  NurseryConnect-TabOS
//
//  The iPad structural backbone (criterion 3): a three-column
//  NavigationSplitView — sidebar (Children / Insights / Incidents) → content
//  list → detail. This replaces the A1 iPhone TabView. Column widths are NOT
//  hard-coded; selection flows through the view models.
//
//  Phase 3 wires the sidebar + roster list + a child-detail *preview* card.
//  Phases 4–6 fill the content/detail columns with the real diary timeline,
//  incident flows and the Swift Charts insights dashboard.
//

import SwiftUI
import SwiftData

struct RootSplitView: View {
    @Environment(\.modelContext) private var context

    @State private var section: SidebarSection? = .children
    @State private var roster: ChildRosterViewModel?
    @State private var incidents: IncidentHistoryViewModel?
    @State private var insights: InsightsViewModel?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @FocusState private var searchFocused: Bool

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } content: {
            contentColumn
        } detail: {
            detailColumn
        }
        .tint(AppColors.brand)
        .background {
            // ⌘F focuses the roster search field (hardware-keyboard bonus).
            Button("Find a child") {
                section = .children
                searchFocused = true
            }
            .keyboardShortcut("f", modifiers: .command)
            .hidden()
        }
        .task {
            if roster == nil {
                let vm = ChildRosterViewModel(service: ChildRosterService(context: context))
                vm.load()
                roster = vm
            }
            if incidents == nil {
                incidents = IncidentHistoryViewModel(service: IncidentService(context: context))
            }
            if insights == nil {
                insights = InsightsViewModel(
                    rosterService: ChildRosterService(context: context),
                    insightsService: InsightsService(context: context)
                )
            }
        }
    }

    // MARK: - Column 1 · Sidebar

    private var sidebar: some View {
        List(selection: $section) {
            ForEach(SidebarSection.allCases) { item in
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title).font(AppTypography.headline)
                        Text(item.subtitle)
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                } icon: {
                    Image(systemName: item.icon)
                        .foregroundStyle(AppColors.brand)
                }
                .padding(.vertical, AppSpacing.xs)
                .tag(item)
            }
        }
        .navigationTitle("NurseryConnect")
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) { keyworkerFooter }
    }

    private var keyworkerFooter: some View {
        HStack(spacing: AppSpacing.sm) {
            ChildAvatar(initials: "SM", seed: 0, size: 32)
            VStack(alignment: .leading, spacing: 0) {
                Text(SeedDataService.currentKeyworker)
                    .font(AppTypography.footnote.weight(.semibold))
                Text("Keyworker")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(AppSpacing.sm)
        .background(.ultraThinMaterial)
    }

    // MARK: - Column 2 · Content

    @ViewBuilder
    private var contentColumn: some View {
        switch section {
        case .children, .none:
            childListColumn
        case .insights:
            if let insights {
                InsightsScopeList(viewModel: insights)
            } else {
                LoadingView()
            }
        case .incidents:
            if let incidents {
                IncidentHistoryView(viewModel: incidents)
            } else {
                LoadingView()
            }
        }
    }

    @ViewBuilder
    private var childListColumn: some View {
        if let roster {
            Group {
                switch roster.state {
                case .loading, .idle:
                    LoadingView(label: "Loading roster…")
                case .failed(let message):
                    EmptyStateView(icon: "exclamationmark.triangle.fill",
                                   title: "Couldn’t load roster",
                                   message: message,
                                   tint: AppColors.danger)
                case .loaded where roster.children.isEmpty:
                    EmptyStateView(icon: AppIcons.empty,
                                   title: "No children assigned",
                                   message: "Seeded children will appear here.")
                case .loaded where roster.filteredChildren.isEmpty:
                    EmptyStateView(icon: AppIcons.empty,
                                   title: "No matches",
                                   message: "No child matches “\(roster.searchText)”.")
                case .loaded:
                    List(roster.filteredChildren, selection: bindingSelection(roster)) { child in
                        ChildRow(child: child)
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Children")
            .searchable(text: bindingSearch(roster),
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Find a child")
            .searchFocused($searchFocused)
        } else {
            LoadingView()
        }
    }

    // MARK: - Column 3 · Detail

    @ViewBuilder
    private var detailColumn: some View {
        switch section {
        case .children, .none:
            if let child = roster?.selectedChild {
                ChildDetailView(child: child)
                    .id(child.id)
            } else {
                EmptyStateView(icon: AppIcons.children,
                               title: "Select a child",
                               message: "Pick a child from the roster to see their day.")
            }
        case .incidents:
            if let incident = incidents?.selected {
                IncidentDetailView(incident: incident)
            } else {
                EmptyStateView(icon: AppIcons.incidents,
                               title: "Select an incident",
                               message: "Pick a report from the list to review it.")
            }
        case .insights:
            if let insights, let summary = insights.summary {
                InsightsDashboardView(summary: summary)
                    .id(insights.selectedScope)
            } else {
                EmptyStateView(icon: AppIcons.insights,
                               title: "Select a scope",
                               message: "Pick “All children” or a child to see their trends.")
            }
        }
    }

    // MARK: - Helpers

    private func bindingSelection(_ vm: ChildRosterViewModel) -> Binding<Child.ID?> {
        Binding(get: { vm.selectedChildID }, set: { vm.selectedChildID = $0 })
    }

    private func bindingSearch(_ vm: ChildRosterViewModel) -> Binding<String> {
        Binding(get: { vm.searchText }, set: { vm.searchText = $0 })
    }
}

// MARK: - Roster row

private struct ChildRow: View {
    let child: Child

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ChildAvatar(initials: child.initials, seed: child.avatarSeed)
            VStack(alignment: .leading, spacing: 2) {
                Text(child.fullName).font(AppTypography.headline)
                Text("\(child.ageDescription) · \(child.roomName)")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            if child.hasAllergies {
                Image(systemName: AppIcons.allergy)
                    .foregroundStyle(AppColors.danger)
                    .accessibilityLabel("Has allergies")
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    RootSplitView()
        .modelContainer(PreviewData.container)
}
