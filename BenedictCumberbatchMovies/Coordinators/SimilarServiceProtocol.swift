//
//  SimilarServiceProtocol.swift
//  BenedictCumberbatchMovies
//
//  Abstraction to allow injecting a mock similar movies service in tests.
//

import Foundation

protocol SimilarServiceProtocol: AnyObject {
    /// Fetch similar movies for a given TMDB movie id.
    func fetchSimilarMovies(
        for movieID: Int,
        language: String,
        page: Int,
        region: String?
    ) async throws -> [Movie]
}
