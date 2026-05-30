//
//  ErrorAlertModifier.swift
//  NurseryConnect-TabOS
//
//  Reusable error alert so the same style is used everywhere. Binds to an
//  optional message string; the alert shows whenever it is non-nil.
//  (Carried forward from A1.)
//

import SwiftUI

private struct ErrorAlertModifier: ViewModifier {
    @Binding var message: String?

    func body(content: Content) -> some View {
        content.alert(
            "Something went wrong",
            isPresented: Binding(
                get: { message != nil },
                set: { if !$0 { message = nil } }
            ),
            presenting: message
        ) { _ in
            Button("OK", role: .cancel) { message = nil }
        } message: { msg in
            Text(msg)
        }
    }
}

extension View {
    func errorAlert(_ message: Binding<String?>) -> some View {
        modifier(ErrorAlertModifier(message: message))
    }
}
