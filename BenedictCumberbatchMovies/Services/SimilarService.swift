//
//  SimilarService.swift
//  BenedictCumberbatchMovies
//
//  Simple service to fetch similar movies from TMDB
//

import Foundation

actor SimilarService: SimilarServiceProtocol {
    static let shared = SimilarService()

    private init() {}

    func fetchSimilarMovies(for movieID: Int) async throws -> [Movie] {
        let apiKey = await Constants.tmdbAPIKey
        var components = URLComponents(string: "\(await Constants.baseURL)/movie/\(movieID)/similar")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let list = try decoder.decode(MovieResponse.self, from: data)
        return list.results
    }
}
