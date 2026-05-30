//
//  NurseryConnect_TabOSUITests.swift
//  NurseryConnect-TabOSUITests
//
//  End-to-end happy paths: the app launches straight into its content (no login
//  — brief rule), a child's day view opens from the roster with its quick-log /
//  Report Incident affordances, and the Insights section is reachable.
//
//  The NavigationSplitView sidebar auto-collapses in portrait, so navigation
//  reveals it via the "Show Sidebar" control rather than depending on device
//  orientation (which is unreliable under automation).
//

import XCTest

final class NurseryConnect_TabOSUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launched() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        return app
    }

    /// Reveal the split-view sidebar if it is collapsed (portrait / compact).
    /// A no-op when all three columns are already visible.
    @MainActor
    private func revealSidebar(_ app: XCUIApplication) {
        let toggle = app.buttons["Show Sidebar"]
        if toggle.waitForExistence(timeout: 3) { toggle.tap() }
    }

    @MainActor
    func testLaunchesStraightIntoMainFunctionality() throws {
        let app = launched()

        // No login screen — the seeded roster content is immediately present.
        XCTAssertTrue(app.staticTexts["Children"].waitForExistence(timeout: 10),
                      "App should launch straight into the main NurseryConnect shell.")
        XCTAssertTrue(app.staticTexts["Ava Thompson"].waitForExistence(timeout: 5),
                      "The seeded roster should be on screen at launch.")
    }

    @MainActor
    func testOpenChildDayViewAndReportIncidentAffordance() throws {
        let app = launched()

        let ava = app.staticTexts["Ava Thompson"]
        XCTAssertTrue(ava.waitForExistence(timeout: 10), "Seeded roster should be visible.")
        ava.tap()

        // The day view exposes the Report Incident quick action.
        let reportButton = app.buttons["quickAction.reportIncident"]
        XCTAssertTrue(reportButton.waitForExistence(timeout: 5),
                      "Selecting a child should reveal the quick-log + Report Incident bar.")
    }

    @MainActor
    func testNavigateToInsightsSection() throws {
        let app = launched()

        revealSidebar(app)
        let insights = app.staticTexts["Insights"]
        XCTAssertTrue(insights.waitForExistence(timeout: 10),
                      "Insights destination should be reachable from the sidebar.")
        insights.tap()

        // The Insights scope list (content column) offers the roster-wide view.
        XCTAssertTrue(app.staticTexts["All children"].waitForExistence(timeout: 5),
                      "Tapping Insights should show the scope list with the roster overview.")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
