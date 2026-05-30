//
//  MockDispatchService.swift
//  NurseryConnect-TabOS
//
//  Simulates the async "route this incident to the setting manager" step that
//  a production system would perform (EYFS same-day notification). Carried
//  forward from A1 — demonstrates async/await without a real network layer.
//

import Foundation

@MainActor
struct MockDispatchService {
    /// Simulated routing latency.
    var delay: Duration = .seconds(1.5)

    /// Pretends to notify the setting manager. Awaitable, non-blocking.
    func dispatch(incidentID: UUID) async {
        try? await Task.sleep(for: delay)
    }
}
