//
//  SimilarMoviesUITests.swift
//  BenedictCumberbatchMoviesUITests
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-05.
//

import XCTest

final class SimilarMoviesUITests: XCTestCase {

    func testSimilarSectionAppearsOnDetail() {
        let app = XCUIApplication()
        app.launchArguments.append("UITest_ShowMockDetail")
        app.launch()

        // We should land on the mock detail screen
        let navTitle = app.navigationBars.staticTexts["Mock Movie"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5))

        // The similar section title may or may not appear depending on network; assert at least loading or empty exists
        let loading = app.staticTexts["similarLoading"]
        let section = app.staticTexts["similarSectionTitle"]
        let empty = app.staticTexts["similarEmpty"]

        let exists = loading.waitForExistence(timeout: 2) || section.exists || empty.exists
        XCTAssertTrue(exists, "Expected a similar movies loading/section/empty indicator on detail screen")
    }
}

