//
//  Haptics.swift
//  NurseryConnect-TabOS
//
//  Thin wrapper around UINotificationFeedbackGenerator so feedback is never
//  colour-only (accessibility, criterion 7). Carried forward from A1.
//

#if canImport(UIKit)
import UIKit
#endif

enum Haptics {
    static func success() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func error() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
    }

    static func warning() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }
}
