//
//  MovieDetailSimilarTests.swift
//  BenedictCumberbatchMoviesTests
//
//  Created by VIRESH KUMAR SHARMA on 2025-11-05.
//

import XCTest
@testable import BenedictCumberbatchMovies

final class MovieDetailSimilarTests: XCTestCase {

    actor MockSimilarService: SimilarServiceProtocol {
        var result: Result<[Movie], Error> = .success([])

        func fetchSimilarMovies(for movieID: Int) async throws -> [Movie] {
            switch result {
            case .success(let movies): return movies
            case .failure(let error): throw error
            }
        }

        // Helper to safely mutate actor-isolated state from tests
        func setResult(_ newResult: Result<[Movie], Error>) {
            self.result = newResult
        }
    }

    @MainActor
    func testLoadsSimilarMoviesAndFiltersSelf() async {
        // Arrange
        let mockService = MockSimilarService()
        let base = Movie(id: 1, title: "Base", overview: "O", posterPath: nil, releaseDate: nil)
        let similar = [
            base, // should be filtered out
            Movie(id: 2, title: "S1", overview: "O", posterPath: nil, releaseDate: nil),
            Movie(id: 3, title: "S2", overview: "O", posterPath: nil, releaseDate: nil)
        ]
        await mockService.setResult(.success(similar))

        let vm = MovieDetailViewModel(movie: base, similarService: mockService)

        // Act: wait briefly for async task to complete
        let exp = expectation(description: "Load similar")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { exp.fulfill() }
        await fulfillment(of: [exp], timeout: 1.0)

        // Assert
        XCTAssertFalse(vm.isLoadingSimilar)
        XCTAssertEqual(vm.similarMovies.map(\.id), [2, 3])
    }

    @MainActor
    func testErrorResultsInEmptySimilar() async {
        // Arrange
        let mockService = MockSimilarService()
        struct DummyError: Error {}
        await mockService.setResult(.failure(DummyError()))

        let vm = MovieDetailViewModel(
            movie: Movie(id: 10, title: "A", overview: "O", posterPath: nil, releaseDate: nil),
            similarService: mockService
        )

        // Act: wait briefly for async task to complete
        let exp = expectation(description: "Load similar")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { exp.fulfill() }
        await fulfillment(of: [exp], timeout: 1.0)

        // Assert
        XCTAssertFalse(vm.isLoadingSimilar)
        XCTAssertTrue(vm.similarMovies.isEmpty)
    }
}
