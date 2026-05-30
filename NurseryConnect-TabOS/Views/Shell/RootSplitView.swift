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
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } content: {
            contentColumn
        } detail: {
            detailColumn
        }
        .tint(AppColors.brand)
        .task {
            guard roster == nil else { return }
            let vm = ChildRosterViewModel(service: ChildRosterService(context: context))
            vm.load()
            roster = vm
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
            EmptyStateView(icon: AppIcons.insights,
                           title: "Development & Wellbeing Insights",
                           message: "Swift Charts trends arrive in Phase 6.")
        case .incidents:
            EmptyStateView(icon: AppIcons.incidents,
                           title: "Incident Reports",
                           message: "The incident history & audit trail arrive in Phase 4.")
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
                case .loaded:
                    List(roster.children, selection: bindingSelection(roster)) { child in
                        ChildRow(child: child)
                    }
                    .listStyle(.inset)
                }
            }
            .navigationTitle("Children")
        } else {
            LoadingView()
        }
    }

    // MARK: - Column 3 · Detail

    @ViewBuilder
    private var detailColumn: some View {
        if section == .children, let child = roster?.selectedChild {
            ChildDetailPreview(child: child)
        } else {
            EmptyStateView(icon: AppIcons.children,
                           title: "Select a child",
                           message: "Pick a child from the roster to see their day.")
        }
    }

    // MARK: - Helpers

    private func bindingSelection(_ vm: ChildRosterViewModel) -> Binding<Child.ID?> {
        Binding(get: { vm.selectedChildID }, set: { vm.selectedChildID = $0 })
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

// MARK: - Detail preview (placeholder for the Phase 4 ChildDetailView)

private struct ChildDetailPreview: View {
    let child: Child

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                HStack(spacing: AppSpacing.md) {
                    ChildAvatar(initials: child.initials, seed: child.avatarSeed, size: 72)
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(child.fullName).font(AppTypography.largeTitle)
                        Text("\(child.ageDescription) · \(child.roomName) Room")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()
                }

                if child.hasAllergies || !child.dietaryNotes.isEmpty || !child.photographyConsent {
                    FlowChips(child: child)
                }

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Day view")
                        .sectionHeaderStyle()
                    Text("The diary timeline, quick-log actions and the “Report Incident” flow land here in Phase 4.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .navigationTitle(child.firstName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FlowChips: View {
    let child: Child

    var body: some View {
        ViewThatFits(in: .horizontal) {
            chips
            ScrollView(.horizontal, showsIndicators: false) { chips }
        }
    }

    private var chips: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(child.allergies, id: \.self) { allergen in
                Chip(text: allergen, systemImage: AppIcons.allergy, tint: AppColors.danger)
            }
            if !child.dietaryNotes.isEmpty {
                Chip(text: child.dietaryNotes, systemImage: AppIcons.dietary, tint: AppColors.warning)
            }
            if !child.photographyConsent {
                Chip(text: "No photography", systemImage: AppIcons.noPhoto, tint: AppColors.danger)
            }
        }
    }
}

#Preview {
    RootSplitView()
        .modelContainer(PreviewData.container)
}
