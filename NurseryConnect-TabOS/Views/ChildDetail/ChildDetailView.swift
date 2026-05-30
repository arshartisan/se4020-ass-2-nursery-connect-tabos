//
//  ChildDetailView.swift
//  NurseryConnect-TabOS
//
//  The child "day view" — the detail column of the iPad split view. Header
//  card, safety-critical allergy/consent chips, quick-log actions, and the
//  per-child diary timeline. Diary entry = sheet; incident = full-screen cover
//  (A1 navigation contract carried forward).
//

import SwiftUI
import SwiftData

struct ChildDetailView: View {
    let child: Child
    @Environment(\.modelContext) private var context

    @State private var viewModel: ChildDetailViewModel?
    @State private var diaryFormVM: DiaryEntryFormViewModel?
    @State private var showingIncidentForm = false

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel)
            } else {
                LoadingView()
            }
        }
        .background(AppColors.background)
        .task(id: child.id) { ensureViewModel() }
    }

    // MARK: - Content

    private func content(_ vm: ChildDetailViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                header
                safetyChips
                QuickActionsBar(
                    onLog: { type in diaryFormVM = vm.makeDiaryFormViewModel(type: type) },
                    onReportIncident: { showingIncidentForm = true }
                )
                .cardStyle()
                timeline(vm)
            }
            .padding(AppSpacing.lg)
        }
        .navigationTitle(child.firstName)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationToast(isPresented: Binding(
            get: { vm.showSavedToast },
            set: { vm.showSavedToast = $0 }
        ), message: "Diary entry saved")
        .errorAlert(Binding(get: { vm.errorMessage }, set: { vm.errorMessage = $0 }))
        .sheet(item: $diaryFormVM) { formVM in
            DiaryEntryFormView(viewModel: formVM) { didSave in
                vm.diaryFormDismissed(didSave: didSave)
            }
            .presentationDetents([.medium, .large])
        }
        .fullScreenCover(isPresented: $showingIncidentForm) {
            IncidentFormView(
                viewModel: IncidentFormViewModel(
                    child: child,
                    incidentService: IncidentService(context: context)
                )
            )
        }
        .background {
            // ⌘N starts a new diary entry for the visible child (keyboard bonus).
            Button("New diary entry") {
                diaryFormVM = vm.makeDiaryFormViewModel(type: .activity)
            }
            .keyboardShortcut("n", modifiers: .command)
            .hidden()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: AppSpacing.md) {
            ChildAvatar(initials: child.initials, seed: child.avatarSeed, size: 72)
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(child.fullName).font(AppTypography.largeTitle)
                Text("\(child.ageDescription) · \(child.roomName) Room")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                Text("Keyworker · \(child.keyworkerName)")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            if !child.photographyConsent {
                Label("No photos", systemImage: AppIcons.noPhoto)
                    .font(AppTypography.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppColors.danger, in: Capsule())
                    .accessibilityLabel("Photography consent not given")
            }
        }
        .cardStyle()
    }

    @ViewBuilder
    private var safetyChips: some View {
        if child.hasAllergies || !child.dietaryNotes.isEmpty {
            ViewThatFits(in: .horizontal) {
                chipRow
                ScrollView(.horizontal, showsIndicators: false) { chipRow }
            }
        }
    }

    private var chipRow: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(child.allergies, id: \.self) { allergen in
                Chip(text: allergen, systemImage: AppIcons.allergy, tint: AppColors.danger)
            }
            if !child.dietaryNotes.isEmpty {
                Chip(text: child.dietaryNotes, systemImage: AppIcons.dietary, tint: AppColors.warning)
            }
        }
    }

    // MARK: - Timeline

    @ViewBuilder
    private func timeline(_ vm: ChildDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Diary timeline")
                .sectionHeaderStyle()

            if vm.entries.isEmpty {
                EmptyStateView(icon: AppIcons.empty,
                               title: "Nothing logged yet",
                               message: "Use the quick-log buttons above to start \(child.firstName)’s day.")
                .frame(minHeight: 220)
            } else {
                VStack(spacing: 0) {
                    ForEach(vm.entries) { entry in
                        DiaryEntryRow(entry: entry)
                        if entry.id != vm.entries.last?.id {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
                .cardStyle()
            }
        }
    }

    // MARK: - Setup

    private func ensureViewModel() {
        if viewModel == nil {
            let vm = ChildDetailViewModel(child: child,
                                          diaryService: DiaryService(context: context))
            vm.loadEntries()
            viewModel = vm
        } else {
            viewModel?.loadEntries()
        }
    }
}
