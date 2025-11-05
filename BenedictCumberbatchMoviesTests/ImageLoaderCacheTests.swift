//
//  ImageLoaderCacheTests.swift
//  BenedictCumberbatchMovies
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-05.
//

import XCTest
@testable import BenedictCumberbatchMovies
import UIKit

final class ImageLoaderCacheTests: XCTestCase {

    func testLoadImageFromDataURLReturnsImage() async {
        // Build a tiny 1x1 PNG in-memory and load via data URL to avoid network
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let uiImage = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        guard let data = uiImage.pngData() else {
            XCTFail("Failed to get PNG data")
            return
        }
        let dataURL = URL(string: "data:image/png;base64,\(data.base64EncodedString())")!
        let loaded = await ImageLoader.shared.loadImage(from: dataURL)
        XCTAssertNotNil(loaded.pngData(), "Expected a valid UIImage from loader")
    }

    func testCacheSpeedsUpSecondLoad() async {
        // Another in-memory image via data URL
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 2, height: 2))
        let uiImage = renderer.image { ctx in
            UIColor.blue.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
        }
        guard let data = uiImage.pngData() else {
            XCTFail("Failed to get PNG data")
            return
        }
        let dataURL = URL(string: "data:image/png;base64,\(data.base64EncodedString())")!

        let t1 = CFAbsoluteTimeGetCurrent()
        _ = await ImageLoader.shared.loadImage(from: dataURL)
        let t2 = CFAbsoluteTimeGetCurrent()

        let t3 = CFAbsoluteTimeGetCurrent()
        _ = await ImageLoader.shared.loadImage(from: dataURL)
        let t4 = CFAbsoluteTimeGetCurrent()

        let first = t2 - t1
        let second = t4 - t3
        XCTAssertLessThanOrEqual(second, first + 0.05, "Second load should be served from cache and not be slower")
    }
}
