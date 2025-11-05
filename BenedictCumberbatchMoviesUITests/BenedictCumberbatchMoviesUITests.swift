//
//  BenedictCumberbatchMoviesUITests.swift
//  BenedictCumberbatchMoviesUITests
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import XCTest

final class BenedictCumberbatchMoviesUITests: XCTestCase {

    func testDetailScreenRendersMockMovie() {
        let app = XCUIApplication()
        app.launchArguments.append("UITest_ShowMockDetail")
        app.launch()

        // Verify navigation title
        let navTitle = app.navigationBars.staticTexts["Mock Movie"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5), "Expected Mock Movie title in navigation bar")

        // Verify overview text exists
        let overview = app.staticTexts["A mock overview for UI testing."]
        XCTAssertTrue(overview.waitForExistence(timeout: 5), "Expected overview text on detail screen")

        // Ensure scroll view exists
        XCTAssertTrue(app.scrollViews.element.waitForExistence(timeout: 5), "Expected a ScrollView on detail screen")
    }
}
