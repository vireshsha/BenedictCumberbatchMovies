//
//  SimilarServiceProtocol.swift
//  BenedictCumberbatchMovies
//
//  Abstraction to allow injecting a mock similar movies service in tests.
//

import Foundation

protocol SimilarServiceProtocol: AnyObject {
    func fetchSimilarMovies(for movieID: Int) async throws -> [Movie]
}

