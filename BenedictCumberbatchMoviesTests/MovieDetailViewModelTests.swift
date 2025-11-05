//
//  MovieDetailViewModelTests.swift
//  BenedictCumberbatchMoviesTests
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-05.
//

import XCTest
import Combine
@testable import BenedictCumberbatchMovies

@MainActor
final class MovieDetailViewModelTests: XCTestCase {

    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - 1. Initialization

    func testInitStoresMovie_withAllFields() {
        // Arrange
        let movie = Movie(
            id: 101,
            title: "Unit Test Movie",
            overview: "Overview text",
            posterPath: "/poster.png",
            releaseDate: "2025-01-01"
        )

        // Act
        let vm = MovieDetailViewModel(movie: movie)

        // Assert
        XCTAssertEqual(vm.movie.id, 101)
        XCTAssertEqual(vm.movie.title, "Unit Test Movie")
        XCTAssertEqual(vm.movie.overview, "Overview text")
        XCTAssertEqual(vm.movie.posterPath, "/poster.png")
        XCTAssertEqual(vm.movie.releaseDate, "2025-01-01")
    }

    // MARK: - 2. Published Property Emits

    func testPublishedMovieEmitsWhenReplaced() async {
        // Arrange
        let initialMovie = Movie(id: 1, title: "A", overview: "O1", posterPath: nil, releaseDate: "2020-01-01")
        let updatedMovie = Movie(id: 2, title: "B", overview: "O2", posterPath: nil, releaseDate: "2021-02-02")

        let vm = MovieDetailViewModel(movie: initialMovie)

        var publishedValues: [Movie] = []
        let expectation = XCTestExpectation(description: "Published movie emits new value")

        vm.$movie
            .dropFirst() // skip initial
            .sink { movie in
                publishedValues.append(movie)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        vm.movie = updatedMovie

        // Assert
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(publishedValues.count, 1)
        XCTAssertEqual(publishedValues.first?.id, 2)
    }

    // MARK: - 3. Published Emits Multiple Updates

    func testPublishedMovieEmitsMultipleUpdates() async {
        // Arrange
        let vm = MovieDetailViewModel(movie: Movie(id: 1, title: "A", overview: "O1", posterPath: nil, releaseDate: nil))

        let expectation = XCTestExpectation(description: "Emits multiple updates")
        expectation.expectedFulfillmentCount = 2

        var receivedIDs: [Int] = []

        vm.$movie
            .dropFirst()
            .sink { movie in
                receivedIDs.append(movie.id)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Act
        vm.movie = Movie(id: 2, title: "B", overview: "O2", posterPath: nil, releaseDate: nil)
        vm.movie = Movie(id: 3, title: "C", overview: "O3", posterPath: nil, releaseDate: nil)

        // Assert
        await fulfillment(of: [expectation], timeout: 1)
        XCTAssertEqual(receivedIDs, [2, 3])
    }

    // MARK: - 4. Thread Safety (MainActor isolation)

    func testMovieUpdateIsMainActorIsolated() async {
        // Arrange
        let vm = MovieDetailViewModel(movie: Movie(id: 1, title: "Start", overview: "O", posterPath: nil, releaseDate: nil))

        // Act
        await MainActor.run {
            vm.movie = Movie(id: 99, title: "Updated", overview: "O2", posterPath: nil, releaseDate: nil)
        }

        // Assert
        XCTAssertEqual(vm.movie.id, 99)
        XCTAssertEqual(vm.movie.title, "Updated")
    }
}
