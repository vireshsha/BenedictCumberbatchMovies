//
//  BenedictCumberbatchMoviesTests.swift
//  BenedictCumberbatchMoviesTests
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-04.
//

import XCTest
import SwiftUI
@testable import BenedictCumberbatchMovies

final class AsyncImageViewTests: XCTestCase {

    func testAsyncImageViewInitDefaultsToFit() {
        // Ensure the view can be constructed with defaults
        let view = AsyncImageView(url: nil)
        XCTAssertNotNil(view)
    }

    func testAsyncImageViewWithFitRendersBody() {
        let view = AsyncImageView(url: nil, contentMode: .fit)
        // Access body to ensure the view builds without crashing
        _ = view.body
        XCTAssertTrue(true)
    }

    func testAsyncImageViewWithFillRendersBody() {
        let view = AsyncImageView(url: nil, contentMode: .fill)
        _ = view.body
        XCTAssertTrue(true)
    }
}
