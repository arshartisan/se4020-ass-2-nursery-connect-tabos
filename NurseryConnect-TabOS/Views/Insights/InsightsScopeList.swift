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
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(child.fullName).font(AppTypography.headline)
                                    Text(child.roomName)
                                        .font(AppTypography.footnote)
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                            } icon: {
                                ChildAvatar(initials: child.initials, seed: child.avatarSeed, size: 32)
                            }
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
