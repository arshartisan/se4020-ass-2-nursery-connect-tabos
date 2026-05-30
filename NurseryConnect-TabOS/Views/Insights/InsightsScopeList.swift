//
//  InsightsScopeList.swift
//  NurseryConnect-TabOS
//
//  The Insights content column: pick the scope the Swift Charts dashboard
//  summarises — the whole roster, or one child. Selection flows through the
//  InsightsViewModel and drives the detail column (NavigationSplitView).
//

import SwiftUI

struct InsightsScopeList: View {
    @Bindable var viewModel: InsightsViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                LoadingView(label: "Loading insights…")
            case .failed(let message):
                EmptyStateView(icon: "exclamationmark.triangle.fill",
                               title: "Couldn’t load insights",
                               message: message,
                               tint: AppColors.danger)
            case .loaded:
                List(selection: $viewModel.selectedScope) {
                    Section {
                        Label("All children", systemImage: AppIcons.insights)
                            .tag(InsightsScope.roster)
                    } header: {
                        Text("Overview").sectionHeaderStyle()
                    }

                    Section {
                        ForEach(viewModel.children) { child in
                            InsightsChildRow(
                                child: child,
                                isSelected: viewModel.selectedScope == .child(child.id)
                            )
                            .tag(InsightsScope.child(child.id))
                        }
                    } header: {
                        Text("By child").sectionHeaderStyle()
                    }
                }
                .listStyle(.inset)
            }
        }
        .navigationTitle("Insights")
        .task { if viewModel.state == .idle { viewModel.load() } }
    }
}

/// One child in the "By child" scope list. Selection-aware so the row stays
/// legible on the highlighted (brand-blue) background: the subtitle uses the
/// semantic `.secondary` style (which inverts to readable white on selection)
/// and the avatar gets a solid backing so it never blends into the tint.
private struct InsightsChildRow: View {
    let child: Child
    let isSelected: Bool

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(child.fullName).font(AppTypography.headline)
                Text(child.roomName)
                    .font(AppTypography.footnote)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            ChildAvatar(initials: child.initials, seed: child.avatarSeed, size: 32)
                .background(Circle().fill(.white).opacity(isSelected ? 1 : 0))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(child.fullName), \(child.roomName) room")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
