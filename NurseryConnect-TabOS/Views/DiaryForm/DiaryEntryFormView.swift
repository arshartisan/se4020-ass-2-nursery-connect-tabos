//
//  DiaryEntryFormView.swift
//  NurseryConnect-TabOS
//
//  Modal diary form. The body changes by entry type; a common notes +
//  timestamp section sits at the bottom. Save is disabled until valid, shows
//  a progress indicator while the async save runs, and dismisses on success.
//

import SwiftUI

struct DiaryEntryFormView: View {
    @Bindable var viewModel: DiaryEntryFormViewModel
    /// Reports back to the parent whether a save actually happened.
    var onFinish: (_ didSave: Bool) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    typeSpecificFields
                } header: {
                    Text("\(viewModel.type.title) for \(viewModel.child.firstName)")
                        .sectionHeaderStyle()
                }

                Section("Notes") {
                    TextField("Optional note", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section("Time") {
                    DatePicker("Logged at", selection: $viewModel.timestamp)
                        .datePickerStyle(.compact)
                }
            }
            .navigationTitle("Log \(viewModel.type.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onFinish(false); dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) { saveBar }
            .interactiveDismissDisabled(viewModel.isSaving)
            .errorAlert($viewModel.errorMessage)
        }
    }

    // MARK: - Type-specific fields

    @ViewBuilder
    private var typeSpecificFields: some View {
        switch viewModel.type {
        case .activity:  ActivityFields(viewModel: viewModel)
        case .meal:      MealFields(viewModel: viewModel)
        case .nap:       NapFields(viewModel: viewModel)
        case .nappy:     NappyFields(viewModel: viewModel)
        case .wellbeing: WellbeingFields(viewModel: viewModel)
        }
    }

    // MARK: - Save bar

    private var saveBar: some View {
        Button {
            Task {
                let saved = await viewModel.save()
                if saved { onFinish(true); dismiss() }
            }
        } label: {
            if viewModel.isSaving {
                ProgressView().tint(.white)
            } else {
                Text("Save Entry")
            }
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.isValid))
        .disabled(!viewModel.isValid || viewModel.isSaving)
        .padding(AppSpacing.md)
        .background(.bar)
        .accessibilityIdentifier("diaryForm.saveButton")
    }
}

// MARK: - Field subviews (pass the @Bindable VM; bindings flow back)

private struct ActivityFields: View {
    @Bindable var viewModel: DiaryEntryFormViewModel
    var body: some View {
        TextField("Activity name", text: $viewModel.activityName)
            .accessibilityIdentifier("diaryForm.activityName")
    }
}

private struct MealFields: View {
    @Bindable var viewModel: DiaryEntryFormViewModel
    var body: some View {
        Picker("Meal", selection: $viewModel.mealType) {
            ForEach(MealType.allCases) { Text($0.title).tag($0) }
        }
        Picker("Amount eaten", selection: $viewModel.mealAmount) {
            ForEach(MealAmount.allCases) { Text($0.title).tag($0) }
        }
        .pickerStyle(.segmented)
    }
}

private struct NapFields: View {
    @Bindable var viewModel: DiaryEntryFormViewModel
    var body: some View {
        DatePicker("Start", selection: $viewModel.napStart)
        DatePicker("End", selection: $viewModel.napEnd)
        if viewModel.napEnd <= viewModel.napStart {
            Label("End time must be after the start.", systemImage: "exclamationmark.triangle.fill")
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.danger)
        }
    }
}

private struct NappyFields: View {
    @Bindable var viewModel: DiaryEntryFormViewModel
    var body: some View {
        Picker("Type", selection: $viewModel.nappyType) {
            ForEach(NappyType.allCases) { Text($0.title).tag($0) }
        }
        .pickerStyle(.segmented)
    }
}

private struct WellbeingFields: View {
    @Bindable var viewModel: DiaryEntryFormViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Mood")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
            HStack(spacing: AppSpacing.sm) {
                ForEach(WellbeingMood.allCases) { mood in
                    Button {
                        viewModel.wellbeingMood = mood
                    } label: {
                        Text(mood.emoji)
                            .font(.largeTitle)
                            .padding(AppSpacing.xs)
                            .background(
                                Circle().fill(viewModel.wellbeingMood == mood
                                              ? AppColors.brandSoft : .clear)
                            )
                            .overlay(
                                Circle().stroke(viewModel.wellbeingMood == mood
                                                ? AppColors.brand : .clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(mood.title)
                }
            }
            Text(viewModel.wellbeingMood.title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textPrimary)
        }
    }
}
