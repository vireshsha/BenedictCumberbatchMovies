//
//  SimilarService.swift
//  BenedictCumberbatchMovies
//
//  Simple service to fetch similar movies from TMDB
//

import Foundation

actor SimilarService: SimilarServiceProtocol {
    static let shared = SimilarService()

    private let session: URLSession

    // Allow injecting a URLSession for testing/diagnostics; default to shared.
    init(session: URLSession = .shared) {
        self.session = session
    }

    // Protocol requirement: default behavior with language/page/region defaults.
    func fetchSimilarMovies(for movieID: Int) async throws -> [Movie] {
        try await fetchSimilarMovies(for: movieID, language: "en-US", page: 1, region: nil)
    }

    /// Fetch similar movies for a given TMDB movie id.
    /// - Parameters:
    ///   - movieID: The TMDB movie id.
    ///   - language: Optional language (e.g., "en-US"). Defaults to "en-US".
    ///   - page: Optional page number. Defaults to 1.
    ///   - region: Optional region code (ISO 3166-1). If provided, will be sent to TMDB.
    func fetchSimilarMovies(
        for movieID: Int,
        language: String = "en-US",
        page: Int = 1,
        region: String? = nil
    ) async throws -> [Movie] {
        // Capture constants locally to avoid any main-actor inference in Swift 6
        let baseURL = await Constants.baseURL
        let apiKey = await Constants.tmdbAPIKey

        // Build URL
        var components = URLComponents(string: "\(baseURL)/movie/\(movieID)/similar")
        var items: [URLQueryItem] = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "page", value: String(page))
        ]
        if let region, !region.isEmpty {
            items.append(URLQueryItem(name: "region", value: region))
        }
        components?.queryItems = items

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        // Diagnostics: log the request URL in debug builds
        #if DEBUG
        print("SimilarService: Requesting similar movies URL -> \(url.absoluteString)")
        #endif

        do {
            let (data, response) = try await session.data(from: url)

            // Validate HTTP status
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                #if DEBUG
                let bodyPreview = String(data: data, encoding: .utf8) ?? "<non-utf8 body>"
                print("SimilarService: Non-2xx status \(http.statusCode). Body preview: \(bodyPreview)")
                #endif
                // Surface the actual status code instead of collapsing to a generic error
                throw HTTPError.statusCode(http.statusCode)
            }

            // Decode
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            // If MovieResponse (or nested Movie) has a main-actor-isolated Decodable conformance
            // due to referencing @MainActor globals, perform the decode on the main actor.
            let list: MovieResponse = try await MainActor.run {
                try decoder.decode(MovieResponse.self, from: data)
            }
            return list.results
        } catch let urlError as URLError {
            #if DEBUG
            print("SimilarService: URLError \(urlError.code) - \(urlError.localizedDescription)")
            #endif
            throw urlError
        } catch let decoding as DecodingError {
            #if DEBUG
            print("SimilarService: DecodingError - \(decoding)")
            #endif
            throw decoding
        } catch {
            #if DEBUG
            print("SimilarService: Unexpected error - \(error.localizedDescription)")
            #endif
            throw error
        }
    }
}

// Helper to surface HTTP status codes distinctly from URLError
enum HTTPError: Error, LocalizedError {
    case statusCode(Int)

    var errorDescription: String? {
        switch self {
        case .statusCode(let code):
            return "Server responded with status \(code)"
        }
    }
}
