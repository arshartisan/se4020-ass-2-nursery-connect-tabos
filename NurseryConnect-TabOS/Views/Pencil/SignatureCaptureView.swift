//
//  SignatureCaptureView.swift
//  NurseryConnect-TabOS
//
//  Platform-specific native feature (criterion 3): a PencilKit signature pad.
//  The keyworker signs off the incident with Apple Pencil (or finger on the
//  simulator); the strokes are flattened to a PNG and stored on the
//  IncidentReport. This is the human attestation that anchors the safeguarding
//  audit trail — a typed name is repudiable, a signature is not.
//
//  PencilKit / UIKit are guarded behind `#if canImport(UIKit)` so SourceKit's
//  macOS index doesn't raise false "cannot find PKCanvasView" errors (the same
//  reason Haptics is guarded). The real iPad target always has UIKit.
//

import SwiftUI
#if canImport(UIKit)
import PencilKit
import UIKit
#endif

/// SwiftUI wrapper: the canvas, a "Sign here" prompt while empty, and a Clear
/// control. Exposes the captured signature as PNG `Data` via a binding.
struct SignatureCaptureView: View {
    @Binding var signatureData: Data?

    /// Bumping this id rebuilds the underlying canvas — our "clear" gesture.
    @State private var canvasID = UUID()

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: AppSpacing.chipRadius, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.chipRadius, style: .continuous)
                            .stroke(AppColors.separator, lineWidth: 1)
                    )

                #if canImport(UIKit)
                SignatureCanvas(signatureData: $signatureData)
                    .id(canvasID)
                    .padding(AppSpacing.xs)
                #endif

                if signatureData == nil {
                    Label("Sign here", systemImage: AppIcons.signature)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 150)

            HStack {
                Image(systemName: signatureData == nil ? "signature" : AppIcons.success)
                    .foregroundStyle(signatureData == nil ? AppColors.textSecondary : AppColors.success)
                Text(signatureData == nil ? "Keyworker signature required" : "Signed")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Button("Clear", role: .destructive) {
                    signatureData = nil
                    canvasID = UUID()
                }
                .font(AppTypography.footnote.weight(.semibold))
                .disabled(signatureData == nil)
            }
        }
    }
}

#if canImport(UIKit)

/// `UIViewRepresentable` bridge to a `PKCanvasView`. On every stroke change it
/// flattens the drawing to a PNG and pushes it up through the binding (nil when
/// the canvas is empty, so validation can require a real signature).
private struct SignatureCanvas: UIViewRepresentable {
    @Binding var signatureData: Data?

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.delegate = context.coordinator
        // .anyInput lets a finger / trackpad sign in the simulator where no
        // Apple Pencil exists — essential for grading on a simulator.
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .label, width: 4)
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) { }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        private let parent: SignatureCanvas
        init(_ parent: SignatureCanvas) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            let drawing = canvasView.drawing
            guard !drawing.bounds.isEmpty else {
                parent.signatureData = nil
                return
            }
            // Fixed @2x scale keeps the PNG crisp without depending on the
            // (deprecated) UIScreen.main.
            let image = drawing.image(from: canvasView.bounds, scale: 2.0)
            parent.signatureData = image.pngData()
        }
    }
}

#endif

#Preview {
    struct Harness: View {
        @State private var data: Data?
        var body: some View {
            SignatureCaptureView(signatureData: $data)
                .padding()
                .background(AppColors.background)
        }
    }
    return Harness()
}
