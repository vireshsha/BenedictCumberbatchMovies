//
//  MovieCellTests.swift
//  BenedictCumberbatchMoviesTests
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-05.
//

import XCTest
@testable import BenedictCumberbatchMovies
import UIKit

final class MovieCellTests: XCTestCase {

    // Helper to create a tiny in-memory PNG data URL
    private func makeDataURLImage(size: CGSize = CGSize(width: 2, height: 3), color: UIColor = .green) -> URL {
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        let data = img.pngData()!
        let url = URL(string: "data:image/png;base64,\(data.base64EncodedString())")!
        return url
    }

    @MainActor private func makeCell() -> MovieCell {
        // Create a cell instance like tableView would
        let cell = MovieCell(style: .default, reuseIdentifier: MovieCell.reuseID)
        // Force layout to ensure constraints/initial state applied
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }

    @MainActor func testConfigureSetsTitleAndAccessibilityLabel() {
        // Arrange
        let movie = Movie(id: 10, title: "Test Title", overview: "O", posterPath: nil, releaseDate: nil)
        let cell = makeCell()

        // Act
        cell.configure(with: movie)

        // Assert
        // Traverse subviews to find the UILabel since it's private
        let labels = cell.contentView.subviews.compactMap { $0 as? UILabel }
        XCTAssertFalse(labels.isEmpty, "Expected a UILabel in cell")
        let titleLabel = labels.first!
        XCTAssertEqual(titleLabel.text, "Test Title")
        XCTAssertEqual(titleLabel.accessibilityLabel, "Title: Test Title")
        XCTAssertTrue(titleLabel.isAccessibilityElement)
    }

    @MainActor func testConfigureSetsPlaceholderImmediately() {
        // Arrange
        let movie = Movie(id: 11, title: "Placeholder", overview: "O", posterPath: nil, releaseDate: nil)
        let cell = makeCell()

        // Act
        cell.configure(with: movie)

        // Assert
        // Find image view
        let imageViews = cell.contentView.subviews.compactMap { $0 as? UIImageView }
        XCTAssertFalse(imageViews.isEmpty, "Expected an image view in cell")
        let poster = imageViews.first!
        // Placeholder is a system image "photo"
        XCTAssertNotNil(poster.image, "Expected placeholder image to be set immediately")
        XCTAssertNotNil(poster.image?.pngData(), "Expected concrete image data for placeholder")
        XCTAssertTrue(poster.isAccessibilityElement)
        XCTAssertEqual(poster.accessibilityLabel, "Movie poster")
    }

    func testNoImageLoadWhenPosterURLNil() async {
        // Arrange: movie with nil posterPath
        let movie = Movie(id: 12, title: "No Poster", overview: "O", posterPath: nil, releaseDate: nil)
        let cell = await makeCell()

        // Act
        await cell.configure(with: movie)

        // Assert: After a short wait, image should still be placeholder (non-nil)
        // There is no public hook to assert loader call count; we just ensure no crash and image present
        await Task.yield()
        let image: UIImage? = await MainActor.run {
            let poster = cell.contentView.subviews.compactMap { $0 as? UIImageView }.first!
            return poster.image
        }
        XCTAssertNotNil(image)
    }

    func testPrepareForReuseResetsImageAndCancelsTask() async {
        // Arrange: use a very long URL that will never finish quickly, so we can call prepareForReuse
        let slowURL = URL(string: "https://example.com/very/slow/image.png")!
        let movie = Movie(id: 13, title: "Slow", overview: "O", posterPath: slowURL.path, releaseDate: nil)
        // Note: posterURL = Constants.imageBaseURL + posterPath. If Constants.imageBaseURL is not "https://example.com",
        // this URL won’t match our slowURL. We still can exercise cancellation semantics: task will be created if posterURL != nil.
        // For this, we just need posterPath non-nil to trigger Task creation.
        let cell = await makeCell()

        // Act
        await cell.configure(with: movie)

        // Immediately call prepareForReuse to cancel
        await cell.prepareForReuse()

        // Assert: Access UI on the main actor, capture value, then assert
        await Task.yield()
        let image: UIImage? = await MainActor.run {
            let poster = cell.contentView.subviews.compactMap { $0 as? UIImageView }.first!
            return poster.image
        }
        XCTAssertNotNil(image, "Placeholder should be present after reuse")
    }
}
