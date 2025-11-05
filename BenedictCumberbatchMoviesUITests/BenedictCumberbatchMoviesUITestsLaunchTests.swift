//
//  BenedictCumberbatchMoviesUITestsLaunchTests.swift
//  BenedictCumberbatchMoviesUITests
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import XCTest

final class BenedictCumberbatchMoviesUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        // Launch in a deterministic state to avoid flakiness
        app.launchArguments.append("UITest_ShowMockDetail")
        app.launch()

        // Wait for a stable UI element (navigation title on the mock detail screen)
        let navTitle = app.navigationBars.staticTexts["Mock Movie"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 10), "Expected to land on Mock Movie detail screen")

        // Take a screenshot of the ready state
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Detail Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
